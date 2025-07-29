//
//  CurationViewModel.swift
//  Signup
//
//  Created by 권민재 on 7/28/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import Foundation
import Domain
import SwiftUI
import Shared

public protocol ClipboardServiceProtocol {
    func copyToClipboard(_ text: String)
}

public protocol URLServiceProtocol {
    func canOpenURL(_ url: URL) -> Bool
    func openURL(_ url: URL)
}

public struct DefaultClipboardService: ClipboardServiceProtocol {
    public init() {}
    
    public func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
}

public struct DefaultURLService: URLServiceProtocol {
    public init() {}
    
    public func canOpenURL(_ url: URL) -> Bool {
        return UIApplication.shared.canOpenURL(url)
    }
    
    public func openURL(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

@MainActor
public final class CurationViewModel: ObservableObject {
    
    @Published public var recommendedNewsletters: [NewsletterDetail] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showEmailCopiedToast: Bool = false
    
    private let newsletterUseCase: NewsletterUseCase
    private let clipboardService: ClipboardServiceProtocol
    private let urlService: URLServiceProtocol
    private let timerService: TimerServiceProtocol
    public let user: User
    
    private var hideToastTimer: TimerProtocol?
    
    public init(
        newsletterUseCase: NewsletterUseCase, 
        user: User,
        clipboardService: ClipboardServiceProtocol = DefaultClipboardService(),
        urlService: URLServiceProtocol = DefaultURLService(),
        timerService: TimerServiceProtocol = DefaultTimerService()
    ) {
        self.newsletterUseCase = newsletterUseCase
        self.user = user
        self.clipboardService = clipboardService
        self.urlService = urlService
        self.timerService = timerService
    }
    
    public func loadRecommendedNewsletters() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await newsletterUseCase.fetchRecommendation()
            recommendedNewsletters = response.intersection
            
        } catch {
            errorMessage = "추천 뉴스레터를 불러오는데 실패했습니다."
        }
        
        isLoading = false
    }
    
    public func copyEmailToClipboard() {
        clipboardService.copyToClipboard(user.subscribeEmail)
        showEmailCopiedToast = true
        
        hideToastTimer?.invalidate()
        
        hideToastTimer = timerService.scheduleTimer(withTimeInterval: 2.0, repeats: false) { [weak self] in
            Task { @MainActor in
                self?.showEmailCopiedToast = false
            }
        }
    }
    
    public func openSubscribeUrl(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }
        
        copyEmailToClipboard()
        
        if urlService.canOpenURL(url) {
            urlService.openURL(url)
            return true
        }
        
        return false
    }
}

