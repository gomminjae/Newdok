//
//  CurationView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain

public struct CurationView: View {
    @ObservedObject private var viewModel: SignupViewModel
    @EnvironmentObject private var router: AppRouter
    
    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isCurationLoading {
                SignupCurationSkeletonView()
            } else {
                loadedContent
            }
        }
        .padding(.horizontal, 24)
    }
}

private extension CurationView {
    var loadedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요!")
                .font(.hanSansNeo(20,.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
            
            Text("구독한 뉴스레터는 발행일에 맞춰 홈으로 배달해드려요.\n구독하기를 누르면 구독 이메일이 자동으로 복사돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.recommendedPost, id: \.id) { brand in
                        CurationRow(brand: brand, viewModel: viewModel)
                    }
                }
            }
            .padding(.top, 32)
            .scrollIndicators(.hidden)
            
            Button("메인으로") {
                viewModel.reset()
                router.resetTo(.tabbar(selectedTab: .home))
            }
            .font(.hanSansNeo(14, .bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.primaryNormal)
            .cornerRadius(4)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    let mockViewModel = SignupViewModel(userUseCase: MockUserUseCase())
    mockViewModel.nickname = "테스트유저"
    mockViewModel.recommendedPost = [
        RecommendedBrand(
            id: 1,
            name: "NEWNEEK",
            description: "핵심만 꾹꾹 눌러 담은 세상 돌아가는 이야기",
            cycle: "매주 평일 아침",
            subscribeUrl: "https://newneek.co/",
            imageUrl: "https://newdok.shop/public/NEWNEEK.png",
            interests: [
                Interest(id: 1, name: "경제・시사"),
                Interest(id: 2, name: "비즈니스"),
                Interest(id: 4, name: "트렌드")
            ]
        ),
        RecommendedBrand(
            id: 2,
            name: "Daily Byte",
            description: "꼭 알아야 할 비즈니스・경제 이슈, 데일리바이트에서 핵심만 쉽게",
            cycle: "매주 평일 오전 6시",
            subscribeUrl: "https://page.stibee.com/subscriptions/81111",
            imageUrl: "https://newdok.shop/public/Daily Byte.png",
            interests: [
                Interest(id: 1, name: "경제・시사"),
                Interest(id: 2, name: "비즈니스"),
                Interest(id: 8, name: "취미・자기계발")
            ]
        ),
        RecommendedBrand(
            id: 15,
            name: "비잉10",
            description: "멘탈 스타일리스트가 챙겨주는 일잘러를 위한 마음가짐",
            cycle: "격주 목요일 아침",
            subscribeUrl: "https://being10.stibee.com/subscribe/",
            imageUrl: "https://newdok.shop/public/비잉10.png",
            interests: [
                Interest(id: 9, name: "건강・의학"),
                Interest(id: 7, name: "라이프스타일"),
                Interest(id: 10, name: "멘탈케어")
            ]
        ),
        RecommendedBrand(
            id: 29,
            name: "Weekly 호박너구리",
            description: "배움을 즐기고 성장을 추구하는 종합 비지니스 뉴스레터",
            cycle: "비정기 발행",
            subscribeUrl: "https://www.pumpkin-raccoon.com/newsletter",
            imageUrl: "https://newdok.shop/public/Weekly 호박너구리.png",
            interests: [
                Interest(id: 1, name: "경제・시사"),
                Interest(id: 2, name: "비즈니스"),
                Interest(id: 8, name: "취미・자기계발")
            ]
        )
    ]
    
    let loadingViewModel = SignupViewModel(userUseCase: MockUserUseCase())
    loadingViewModel.nickname = "미리보기"
    loadingViewModel.isCurationLoading = true
    
    return Group {
        CurationView(viewModel: mockViewModel)
        CurationView(viewModel: loadingViewModel)
    }
    .environmentObject(AppRouter())
}

// Mock UserUseCase
class MockUserUseCase: UserUseCase {
    func login(loginId: String, password: String) async throws -> (User, String) {
        fatalError("Mock not implemented")
    }
    
    func signup(loginId: String, password: String, phoneNumber: String, nickname: String, birthYear: String, gender: String) async throws -> SignupResponse {
        fatalError("Mock not implemented")
    }
    
    func checkPhoneNumber(_ phoneNumber: String) async throws -> [SimpleUser] {
        fatalError("Mock not implemented")
    }
    
    func checkIDDup(_ loginId: String) async throws -> CheckResult<SimpleUser> {
        fatalError("Mock not implemented")
    }
    
    func updateNickname(_ nickname: String) async throws -> NicknameResponse {
        fatalError("Mock not implemented")
    }
    
    func updatePassword(loginId: String, prevPassword: String, newPassword: String) async throws {
        fatalError("Mock not implemented")
    }
    
    func updateInterest(_ interestsId: [Int]) async throws {
        fatalError("Mock not implemented")
    }
    
    func updateIndustry(_ industryId: Int) async throws {
        fatalError("Mock not implemented")
    }
    
    func updatePhoneNumber(_ phoneNumber: String) async throws {
        fatalError("Mock not implemented")
    }
    
    func authSMS(phoneNumber: String) async throws -> SMSResponse {
        fatalError("Mock not implemented")
    }
    
    func preInvestigate(industryId: String, interestIds: [String]) async throws -> [RecommendedBrand] {
        fatalError("Mock not implemented")
    }
    
    func getProfile() async throws -> User {
        fatalError("Mock not implemented")
    }
    
    func withdraw() async throws {
        fatalError("Mock not implemented")
    }
}
