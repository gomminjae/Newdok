//
//  AccountManagementView.swift
//  Mypage
//
//  Created by 권민재 on 5/11/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import PopupView
import Shared

public struct AccountManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutPopup = false
    @Environment(AppRouter.self) private var router

    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let appState: AppState

    public init(
        tokenStorage: TokenStorageProtocol = TokenStorageWrapper.shared,
        userInfoStore: UserInfoStoreProtocol = UserInfoStore.shared,
        appState: AppState = .shared
    ) {
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.appState = appState
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 휴대폰 번호 변경
            Button {
                router.push(.updatePhoneNumber)
            } label: {
                rowLabel(title: "휴대폰 번호 변경")
            }
            .buttonStyle(.plain)
            .padding(.vertical, 13)

            // 비밀번호 변경
            Button {
                router.push(.updatePassword)
            } label: {
                rowLabel(title: "비밀번호 변경")
            }
            .buttonStyle(.plain)
            .padding(.vertical, 13)

            // 로그아웃 버튼
            Button {
                showLogoutPopup = true
            } label: {
                rowLabel(title: "로그아웃")
            }
            .buttonStyle(.plain)
            .padding(.vertical, 13)

            // 회원탈퇴
            Button(action: {
                router.push(.withdraw)
            }) {
                Text("회원탈퇴")
                    .font(.hanSansNeo(13, .regular))
                    .foregroundColor(Color.captionNeutral)
                    .underline()
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)

            Spacer()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("계정 관리")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .popup(isPresented: $showLogoutPopup) {
            LogoutPopupView(
                onCancel: { showLogoutPopup = false },
                onConfirm: {
                    showLogoutPopup = false
                    tokenStorage.clear()
                    userInfoStore.clear()

                    NotificationCenter.default.post(name: .init("ResetMypageCache"), object: nil)

                    appState.logout()

                    router.resetTo(.login)
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
        .onReceive(NotificationCenter.default.publisher(for: .showToast)) { notification in
            guard let message = notification.object as? String else { return }
            Task { @MainActor in
                ToastCenter.shared.show(message)
            }
        }
    }

    // 공통 라벨
    private func rowLabel(title: String) -> some View {
        HStack {
            Text(title)
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color.captionStrong)
            Spacer()
            Image(asset: DesignSystemAsset.lineRight)
        }
        .contentShape(Rectangle())
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
