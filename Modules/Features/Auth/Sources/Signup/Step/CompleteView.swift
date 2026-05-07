//
//  CompleteView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import UserNotifications
import Shared

struct CompleteView: View {
    var email: String = "newdok12@newdok.site"
    var onNext: () -> Void = {}
    
    @Bindable private var viewModel: SignupViewModel
    @State private var showingNotificationAlert = false
    @Environment(AppRouter.self) private var router
    
    init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀
            Text("뉴스레터 구독을 위한\n이메일이 생성되었어요.")
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .padding(.horizontal, 24)
                .multilineTextAlignment(.leading)

            // 메인 이미지
            Image(asset: DesignSystemAsset.signup)
                .padding(.top, 32)
                .padding(.horizontal, 55)

            // 설명 텍스트
            Text("이제 뉴독으로 구독을 신청할 수 있어요.\n지금 바로 내게 도움이 될 뉴스레터를 만나보세요.")
                .font(.hanSansNeo(14, .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.captionStrong)
                .padding(.horizontal, 24)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 4) {
                Text("구독 이메일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.top, 20)
                    .padding(.leading, 20)

                Text(viewModel.user?.subscribeEmail ?? "newdok12@newdok.site")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.primaryNormal)
                    .padding(.top, 8)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                    .onAppear {
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 90)
            .background(Color.bgElevated)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            // 다음 버튼
            Button(action: {
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.white)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
}

// #Preview {
//    CompleteView()
// }
