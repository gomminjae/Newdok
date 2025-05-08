//
//  ArticleView.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI
import DesignSystem
import Shared

public struct MypageView: View {
    
    @State private var userInfo: UserInfo?
    
    
    @State private var showToast: Bool = false
    @State private var showEmailAlert: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - 상단 프로필 영역
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(userInfo?.nickname ?? "")
                            .font(.hanSansNeo(16, .bold))
                            .padding(.top, 32)
                        
                        HStack(spacing: 4) {
                            Text("구독이메일")
                                .font(.hanSansNeo(14,.medium))
                                .foregroundColor(Color(hex: "#565656"))
                            Button(action: {
                                showEmailAlert = true
                            }) {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#565656"))
                            }
                        }
                        .padding(.top, 12)
                        
                        HStack(spacing: 6) {
                            Button(action: {
                                UIPasteboard.general.string = userInfo?.subscribeEmail
                            }) {
                                Image(asset: DesignSystemAsset.lineCopy)
                                    .renderingMode(.template)
                                    .foregroundStyle(Color.primaryNormal)
                            }
                            Text(userInfo?.subscribeEmail ?? "")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#161616"))
                        }
                        
                        NavigationLink(destination: EditProfileView()) {
                            Text("프로필 편집")
                                .font(.hanSansNeo(14, .bold))
                                .foregroundColor(Color(hex: "#565656"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(hex: "#EBEBEB"))
                                }
                        }
                        .padding(.top, 18)

                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - 서비스 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("서비스")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        NavigationLink("계정 관리", destination: Text("계정 관리 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                        NavigationLink("알림 설정", destination: Text("알림 설정 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - 고객센터 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("고객센터")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        NavigationLink("FAQ", destination: Text("FAQ 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                        NavigationLink("서비스 피드백", destination: Text("서비스 피드백 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                        NavigationLink("약관 및 정책", destination: Text("약관 및 정책 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                        NavigationLink("버전", destination: Text("버전 화면"))
                            .buttonStyle(PlainButtonStyle())
                            .settingRowStyle()
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 20)
            }
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            userInfo = UserInfoStore.shared.load()
        }
        .fullScreenCover(isPresented: $showEmailAlert) {
            EmailInfoModalView(isPresented: $showEmailAlert)
                .presentationBackground(Color(hex: "#25242C").opacity(0.6))
        }
    }
}
extension View {
    func settingRowStyle() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
            .padding(.horizontal)
            .background(Color.white)
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
            )
    }
}
