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
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var currentToastMessage: String = ""
    @EnvironmentObject private var router: AppRouter
    
    
    public init() {}


    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 휴대폰 번호 변경
            Button {
                router.push(.updatePhoneNumber)
                
            } label: {
                rowLabel(title: "휴대폰 번호 변경")
            }
            .padding(.vertical, 13)

            // 비밀번호 변경
            Button {
                router.push(.updatePassword)
                
            } label: {
                rowLabel(title: "비밀번호 변경")
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
                router.push(.withdraw)
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
                    // 로그아웃 시 모든 사용자 데이터 초기화
                    TokenStorage.clear()
                    UserInfoStore.shared.clear()
                    
                    // 앱 상태 초기화
                    @AppStorage("isGuest") var isGuest: Bool = true
                    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
                    isGuest = true
                    isLoggedIn = false
                    
                    // AppState를 통한 중앙 집중식 상태 관리
                    AppState.shared.logout()
                    
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
        .onReceive(NotificationCenter.default.publisher(for: .showToast)) { notification in
            if let message = notification.object as? String {
                print("🔔 [AccountManagementView] 토스트 메시지 수신: \(message)")
                print("🔔 [AccountManagementView] 메시지 길이: \(message.count)")
                print("🔔 [AccountManagementView] 메시지가 비어있나?: \(message.isEmpty)")
                
                // 메시지 설정 후 토스트 표시
                DispatchQueue.main.async {
                    currentToastMessage = message
                    toastMessage = message
                    showToast = true
                    print("🔔 [AccountManagementView] toastMessage 설정 후: '\(toastMessage)'")
                    print("🔔 [AccountManagementView] currentToastMessage 설정 후: '\(currentToastMessage)'")
                }
            } else {
                print("❌ [AccountManagementView] 토스트 메시지 파싱 실패")
                print("❌ [AccountManagementView] notification.object: \(String(describing: notification.object))")
            }
        }
        .popup(isPresented: $showToast) {
            ToastView(message: currentToastMessage.isEmpty ? toastMessage : currentToastMessage)
                .padding(.bottom, 50)
                .onAppear {
                    print("🎯 [AccountManagementView] 토스트 표시: \(currentToastMessage.isEmpty ? toastMessage : currentToastMessage)")
                    print("🎯 [AccountManagementView] showToast 상태: \(showToast)")
                    print("🎯 [AccountManagementView] currentToastMessage 길이: \(currentToastMessage.count)")
                    print("🎯 [AccountManagementView] toastMessage 길이: \(toastMessage.count)")
                }
                .id(currentToastMessage.isEmpty ? toastMessage : currentToastMessage) // 메시지가 변경될 때마다 뷰를 새로 생성
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(3)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
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
