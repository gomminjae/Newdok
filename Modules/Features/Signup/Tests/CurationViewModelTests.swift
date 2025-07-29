//
//  CurationViewModelTests.swift
//  SignupTests
//
//  Created by 권민재 on 7/28/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import XCTest
import Domain
import Shared
@testable import Signup

// MARK: - Mock Implementations for Testing
class MockClipboardService: ClipboardServiceProtocol {
    var copiedText: String?
    var copyCallCount = 0
    
    func copyToClipboard(_ text: String) {
        copiedText = text
        copyCallCount += 1
    }
}

class MockURLService: URLServiceProtocol {
    var canOpenURLResult = true
    var openedURLs: [URL] = []
    var canOpenURLCallCount = 0
    var openURLCallCount = 0
    
    func canOpenURL(_ url: URL) -> Bool {
        canOpenURLCallCount += 1
        return canOpenURLResult
    }
    
    func openURL(_ url: URL) {
        openedURLs.append(url)
        openURLCallCount += 1
    }
}

class MockTimerService: TimerServiceProtocol {
    var scheduledTimers: [MockTimer] = []
    
    func scheduleTimer(withTimeInterval: TimeInterval, repeats: Bool, block: @escaping () -> Void) -> TimerProtocol {
        let mockTimer = MockTimer(interval: withTimeInterval, repeats: repeats, block: block)
        scheduledTimers.append(mockTimer)
        return mockTimer
    }
}

class MockTimer: TimerProtocol {
    let interval: TimeInterval
    let repeats: Bool
    let block: () -> Void
    var isInvalidated = false
    
    init(interval: TimeInterval, repeats: Bool, block: @escaping () -> Void) {
        self.interval = interval
        self.repeats = repeats
        self.block = block
    }
    
    func invalidate() {
        isInvalidated = true
    }
    
    func fire() {
        if !isInvalidated {
            block()
        }
    }
}

class MockNewsletterUseCase: NewsletterUseCase {
    var fetchRecommendationResult: Result<NewsletterRecommendationResponse, Error> = .success(
        NewsletterRecommendationResponse(intersection: [], union: [])
    )
    var fetchRecommendationCallCount = 0
    
    func fetchRecommendation() async throws -> NewsletterRecommendationResponse {
        fetchRecommendationCallCount += 1
        
        switch fetchRecommendationResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Tests
@MainActor
final class CurationViewModelTests: XCTestCase {
    
    var sut: CurationViewModel!
    var mockNewsletterUseCase: MockNewsletterUseCase!
    var mockClipboardService: MockClipboardService!
    var mockURLService: MockURLService!
    var mockTimerService: MockTimerService!
    var testUser: User!
    
    override func setUp() {
        super.setUp()
        
        testUser = User(
            id: "test-id",
            loginId: "testuser",
            nickname: "테스트유저",
            subscribeEmail: "test@example.com",
            phoneNumber: "01012345678",
            birthYear: "1990",
            gender: "M"
        )
        
        mockNewsletterUseCase = MockNewsletterUseCase()
        mockClipboardService = MockClipboardService()
        mockURLService = MockURLService()
        mockTimerService = MockTimerService()
        
        sut = CurationViewModel(
            newsletterUseCase: mockNewsletterUseCase,
            user: testUser,
            clipboardService: mockClipboardService,
            urlService: mockURLService,
            timerService: mockTimerService
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNewsletterUseCase = nil
        mockClipboardService = nil
        mockURLService = nil
        mockTimerService = nil
        testUser = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func test_init_shouldSetUser() {
        XCTAssertEqual(sut.user.id, testUser.id)
        XCTAssertEqual(sut.user.nickname, testUser.nickname)
        XCTAssertEqual(sut.user.subscribeEmail, testUser.subscribeEmail)
    }
    
    func test_init_shouldSetInitialState() {
        XCTAssertTrue(sut.recommendedNewsletters.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showEmailCopiedToast)
    }
    
    // MARK: - loadRecommendedNewsletters Tests
    func test_loadRecommendedNewsletters_success_shouldUpdateRecommendedNewsletters() async {
        // Given
        let expectedNewsletters = [
            NewsletterDetail(id: "1", name: "뉴스레터1", description: "설명1", subscribeUrl: "http://example1.com"),
            NewsletterDetail(id: "2", name: "뉴스레터2", description: "설명2", subscribeUrl: "http://example2.com")
        ]
        mockNewsletterUseCase.fetchRecommendationResult = .success(
            NewsletterRecommendationResponse(intersection: expectedNewsletters, union: [])
        )
        
        // When
        await sut.loadRecommendedNewsletters()
        
        // Then
        XCTAssertEqual(sut.recommendedNewsletters.count, 2)
        XCTAssertEqual(sut.recommendedNewsletters[0].name, "뉴스레터1")
        XCTAssertEqual(sut.recommendedNewsletters[1].name, "뉴스레터2")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockNewsletterUseCase.fetchRecommendationCallCount, 1)
    }
    
    func test_loadRecommendedNewsletters_failure_shouldSetErrorMessage() async {
        // Given
        mockNewsletterUseCase.fetchRecommendationResult = .failure(NSError(domain: "Test", code: 0))
        
        // When
        await sut.loadRecommendedNewsletters()
        
        // Then
        XCTAssertTrue(sut.recommendedNewsletters.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.errorMessage, "추천 뉴스레터를 불러오는데 실패했습니다.")
        XCTAssertEqual(mockNewsletterUseCase.fetchRecommendationCallCount, 1)
    }
    
    func test_loadRecommendedNewsletters_shouldSetLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state should be managed")
        
        // When
        Task {
            await sut.loadRecommendedNewsletters()
            expectation.fulfill()
        }
        
        // Then - 로딩 시작 시
        XCTAssertTrue(sut.isLoading)
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Then - 로딩 완료 시
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - copyEmailToClipboard Tests
    func test_copyEmailToClipboard_shouldCopyUserEmail() {
        // When
        sut.copyEmailToClipboard()
        
        // Then
        XCTAssertEqual(mockClipboardService.copiedText, testUser.subscribeEmail)
        XCTAssertEqual(mockClipboardService.copyCallCount, 1)
        XCTAssertTrue(sut.showEmailCopiedToast)
    }
    
    func test_copyEmailToClipboard_shouldScheduleToastHide() {
        // When
        sut.copyEmailToClipboard()
        
        // Then
        XCTAssertEqual(mockTimerService.scheduledTimers.count, 1)
        XCTAssertEqual(mockTimerService.scheduledTimers[0].interval, 2.0)
        XCTAssertFalse(mockTimerService.scheduledTimers[0].repeats)
    }
    
    func test_copyEmailToClipboard_multipleCalls_shouldInvalidatePreviousTimer() {
        // Given
        sut.copyEmailToClipboard()
        let firstTimer = mockTimerService.scheduledTimers[0]
        
        // When
        sut.copyEmailToClipboard()
        
        // Then
        XCTAssertTrue(firstTimer.isInvalidated)
        XCTAssertEqual(mockTimerService.scheduledTimers.count, 2)
    }
    
    // MARK: - openSubscribeUrl Tests
    func test_openSubscribeUrl_validURL_shouldReturnTrue() {
        // Given
        let validURL = "https://example.com"
        
        // When
        let result = sut.openSubscribeUrl(validURL)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(mockURLService.openedURLs.count, 1)
        XCTAssertEqual(mockURLService.openedURLs[0].absoluteString, validURL)
        XCTAssertEqual(mockURLService.canOpenURLCallCount, 1)
        XCTAssertEqual(mockURLService.openURLCallCount, 1)
        XCTAssertTrue(sut.showEmailCopiedToast) // 이메일 복사도 호출됨
    }
    
    func test_openSubscribeUrl_invalidURL_shouldReturnFalse() {
        // Given
        let invalidURL = "invalid-url"
        
        // When
        let result = sut.openSubscribeUrl(invalidURL)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(mockURLService.openedURLs.count, 0)
        XCTAssertEqual(mockURLService.canOpenURLCallCount, 0)
        XCTAssertEqual(mockURLService.openURLCallCount, 0)
        XCTAssertTrue(sut.showEmailCopiedToast) // 이메일 복사는 여전히 호출됨
    }
    
    func test_openSubscribeUrl_cannotOpenURL_shouldReturnFalse() {
        // Given
        let validURL = "https://example.com"
        mockURLService.canOpenURLResult = false
        
        // When
        let result = sut.openSubscribeUrl(validURL)
        
        // Then
        XCTAssertFalse(result)
        XCTAssertEqual(mockURLService.openedURLs.count, 0)
        XCTAssertEqual(mockURLService.canOpenURLCallCount, 1)
        XCTAssertEqual(mockURLService.openURLCallCount, 0)
        XCTAssertTrue(sut.showEmailCopiedToast) // 이메일 복사는 여전히 호출됨
    }
} 