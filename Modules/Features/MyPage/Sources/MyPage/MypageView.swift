//
//  ArticleView.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI
import DesignSystem
import Shared
import PopupView

public struct MypageView: View {
    @State private var showToast: Bool = false
    @State private var showEmailAlert: Bool = false
    
    @State private var isCopy: Bool = false
    @State private var showLogoutPopup: Bool = false

    @State private var viewModel: MypageViewModel

    private let onEditProfile: () -> Void
    private let onEditAlert: () -> Void
    private let onFAQ: () -> Void
    private let onFeedback: () -> Void
    private let onTermsMenu: () -> Void
    private let onLogout: () -> Void
    private let onWithdraw: () -> Void

    public init(
        viewModel: MypageViewModel,
        onEditProfile: @escaping () -> Void,
        onEditAlert: @escaping () -> Void,
        onFAQ: @escaping () -> Void,
        onFeedback: @escaping () -> Void,
        onTermsMenu: @escaping () -> Void,
        onLogout: @escaping () -> Void,
        onWithdraw: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onEditProfile = onEditProfile
        self.onEditAlert = onEditAlert
        self.onFAQ = onFAQ
        self.onFeedback = onFeedback
        self.onTermsMenu = onTermsMenu
        self.onLogout = onLogout
        self.onWithdraw = onWithdraw
    }

    public var body: some View {
        VStack(spacing: 0) {
                // MARK: - 상단 프로필 영역
                MypageProfileSection(
                    nickname: viewModel.displayNickname,
                    subscribeEmail: viewModel.displaySubscribeEmail,
                    onEditProfile: {
                        onEditProfile()
                    },
                    onCopyEmail: {
                        viewModel.copySubscribeEmail()
                        isCopy = true
                        Task {
                            try await Task.sleep(for: .seconds(2.1))
                            withAnimation {
                                isCopy = false
                            }
                        }
                    },
                    onShowEmailInfo: {
                        showEmailAlert = true
                    }
                )

                // MARK: - 서비스 섹션
                VStack(spacing: 0) {
                    sectionHeader(title: "서비스")
                    MypageMenuRow(title: "알림 설정") { onEditAlert() }
                }
                .padding(.horizontal, 20)

                // MARK: - 고객센터 섹션
                VStack(spacing: 0) {
                    sectionHeader(title: "고객센터")
                    MypageMenuRow(title: "FAQ") { onFAQ() }
                    MypageMenuRow(title: "서비스 피드백") { onFeedback() }
                    MypageMenuRow(title: "약관 및 정책") { onTermsMenu() }
                    HStack {
                        Text("버전")
                            .font(.hanSansNeo(16, .medium))
                            .foregroundStyle(Color.captionStrong)
                        Spacer()
                        Text("1.0.0")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundColor(Color.captionAssistive)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 48)
                    .background(Color.white)
                }
                .padding(.horizontal, 20)

                Spacer()

                // MARK: - 로그아웃 / 회원탈퇴
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        showLogoutPopup = true
                    } label: {
                        Text("로그아웃")
                            .font(.hanSansNeo(16, .medium))
                            .foregroundStyle(Color.captionStrong)
                            .frame(height: 48)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        onWithdraw()
                    } label: {
                        Text("회원탈퇴")
                            .font(.hanSansNeo(13, .regular))
                            .foregroundColor(Color.captionNeutral)
                            .underline()
                            .frame(height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
            .padding(.top, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("마이페이지")
                        .font(.hanSansNeo(18, .bold))
                        .foregroundColor(.black)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.loadUserInfo()
                Task {
                    await viewModel.fetchuserInfo()
                }
            }
            .popup(isPresented: $showEmailAlert) {
                EmailInfoModalView(isPresented: $showEmailAlert)
            } customize: {
                $0
                    .type(.default)
                    .position(.center)
                    .closeOnTapOutside(true)
                    .backgroundColor(Color.black.opacity(0.3))
            }
            .popup(isPresented: $showLogoutPopup) {
                LogoutPopupView(
                    onCancel: { showLogoutPopup = false },
                    onConfirm: {
                        showLogoutPopup = false
                        onLogout()
                    }
                )
            } customize: {
                $0
                    .type(.default)
                    .position(.center)
                    .closeOnTapOutside(false)
                    .closeOnTap(false)
                    .allowTapThroughBG(false)
                    .backgroundColor(Color.black.opacity(0.3))
            }
            .popup(isPresented: $isCopy) {
                ToastView(message: "구독 이메일 주소가 복사되었습니다.")
                    .padding(.bottom, 106)
            } customize: {
                $0
                    .type(.toast)
                    .position(.bottom)
                    .autohideIn(1)
                    .animation(.easeInOut)
                    .closeOnTapOutside(false)
            }
            .serverErrorPopup(
                error: $viewModel.currentError,
                onRetry: { Task { await viewModel.fetchuserInfo() } }
            )
    }

    // MARK: - 셀 스타일
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.hanSansNeo(12, .regular))
                .foregroundColor(Color.captionAssistive)
            Spacer()
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

private struct LogoutPopupView: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.grayMedium)

            Text("로그아웃 할까요?")
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color.captionHeavy)

            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(Color.captionNeutral)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.lineNeutral)
                        )
                }

                Button(action: onConfirm) {
                    Text("로그아웃")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}
