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

    private let tokenStorage: TokenStorageProtocol
    private let userInfoStore: UserInfoStoreProtocol
    private let appState: AppState
    private let onLogoutCleanup: () -> Void
    private let onBack: () -> Void
    private let onWithdraw: () -> Void
    private let onLoggedOut: () -> Void

    public init(
        tokenStorage: TokenStorageProtocol,
        userInfoStore: UserInfoStoreProtocol,
        appState: AppState,
        onLogoutCleanup: @escaping () -> Void = {},
        onBack: @escaping () -> Void,
        onWithdraw: @escaping () -> Void,
        onLoggedOut: @escaping () -> Void
    ) {
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.appState = appState
        self.onLogoutCleanup = onLogoutCleanup
        self.onBack = onBack
        self.onWithdraw = onWithdraw
        self.onLoggedOut = onLoggedOut
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                onWithdraw()
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
                Button(action: { onBack() }) {
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
                    onLogoutCleanup()
                    appState.logout()
                    onLoggedOut()
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
