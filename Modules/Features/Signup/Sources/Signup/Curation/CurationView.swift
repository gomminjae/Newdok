//
//  CurationView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem
import Domain
import Shared

struct CurationView: View {
    @StateObject private var viewModel: CurationViewModel
    @EnvironmentObject private var router: AppRouter
    
    init(user: User, newsletterUseCase: NewsletterUseCase) {
        _viewModel = StateObject(wrappedValue: CurationViewModel(
            newsletterUseCase: newsletterUseCase, 
            user: user
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.user.nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요!")
                .font(.hanSansNeo(20,.bold))
                .padding(.top, 24)
            
            Text("구독한 뉴스레터는 발행일에 맞춰 홈으로 배달해드려요.\n구독하기를 누르면 구독 이메일이 자동으로 복사돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 8)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.recommendedNewsletters, id: \.id) { newsletter in
                            CurationRow(newsletter: newsletter) {
                                viewModel.openSubscribeUrl(newsletter.subscribeUrl)
                            }
                        }
                    }
                }
                .padding(.top, 32)
                .scrollIndicators(.hidden)
            }
            
            Button("메인으로") {
                // 메인 화면으로 이동
                router.resetTo(.home)
            }
            .font(.hanSansNeo(14, .bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.primaryNormal)
            .cornerRadius(4)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
        .onAppear {
            Task {
                await viewModel.loadRecommendedNewsletters()
            }
        }
        .popup(isPresented: $viewModel.showEmailCopiedToast) {
            ToastView(message: "이메일이 복사되었습니다")
        }
    }
}

//#Preview {
//    CurationView(
//        user: User(
//            id: 1,
//            loginId: "test",
//            phoneNumber: "010-1234-5678",
//            subscribeEmail: "test@example.com",
//            nickname: "테스트",
//            birthYear: "1990",
//            gender: "남성",
//            createdAt: "2025-01-01",
//            industryId: 1,
//            interests: []
//        ), 
//        newsletterUseCase: NewsletterUseCaseImpl(repository: NewsletterRepositoryImpl(provider: MoyaProvider<NewsletterAPI>()))
//    )
//}
