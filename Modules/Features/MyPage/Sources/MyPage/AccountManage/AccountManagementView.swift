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
    @EnvironmentObject private var router: AppRouter
    
    
    public init() {}


    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 휴대폰 번호 변경
            Button("휴대폰 번호 변경") {
                router.push(.updatePhoneNumber)
            }
            .padding(.vertical, 13)

            // 비밀번호 변경
            Button("비밀번호 변경") {
                router.push(.updatePassword)
            }
            .padding(.vertical, 13)

            // 로그아웃 버튼
            Button {
                showLogoutPopup = true
                
            } label: {
                rowLabel(title: "로그아웃")
            }
            .padding(.vertical, 13)

            // 회원탈퇴
            Button(action: {
                // 회원탈퇴 처리
            }) {
                Text("회원탈퇴")
                    .font(.hanSansNeo(13, .regular))
                    .foregroundColor(Color(hex: "565656"))
                    .underline()
            }
            .padding(.vertical, 13)

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
                    TokenStorage.clear()
                    router.resetTo(.login)
                    
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .closeOnTapOutside(false)
                .backgroundColor(Color.black.opacity(0.3))
        }
    }

    // 공통 라벨
    private func rowLabel(title: String) -> some View {
        HStack {
            Text(title)
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "363636"))
            Spacer()
            Image(asset: DesignSystemAsset.lineRight)
        }
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
                .foregroundColor(Color(hex: "C4C4C4"))

            Text("로그아웃 할까요?")
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color(hex: "161616"))

            HStack(spacing: 8) {
                Button(action: onCancel) {
                    Text("취소")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(Color(hex: "565656"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "EBEBEB"))
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
