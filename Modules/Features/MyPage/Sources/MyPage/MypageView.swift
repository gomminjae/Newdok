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
    @State private var userInfo: UserInfo?
    @State private var showToast: Bool = false
    @State private var showEmailAlert: Bool = false
    
    @State private var isCopy: Bool = false
    
    @Environment(AppRouter.self) private var router
    
    @State private var viewModel: MypageViewModel

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
                // MARK: - 상단 프로필 영역
                VStack(alignment: .leading, spacing: 16) {
                    // 닉네임 (최대 2줄)
                    Text(viewModel.user?.nickname ?? userInfo?.nickname ?? "")
                        .font(.hanSansNeo(16, .bold))
                        .lineLimit(2)
                        .padding(.top, 32)

                    // 구독이메일 라벨 + 툴팁
                    HStack(spacing: 4) {
                        Text("구독이메일")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundColor(Color.captionNeutral)
                        Button {
                            showEmailAlert = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 13))
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // 이메일 텍스트 + 복사 버튼
                    HStack(spacing: 6) {
                        Button {
                            let email = viewModel.user?.subscribeEmail ?? userInfo?.subscribeEmail ?? ""
                            UIPasteboard.general.string = email
                            isCopy = true

                            Task {
                                try? await Task.sleep(for: .seconds(2.1))
                                withAnimation {
                                    isCopy = false
                                }
                            }
                        } label: {
                            Image(asset: DesignSystemAsset.lineCopy)
                                .renderingMode(.template)
                                .foregroundStyle(Color.primaryNormal)
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Text(viewModel.user?.subscribeEmail ?? userInfo?.subscribeEmail ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(Color.captionHeavy)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    // 프로필 편집 버튼 (가로 전체)
                    Button {
                        router.push(.editProfile)
                    } label: {
                        Text("프로필 편집")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(Color.captionNeutral)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .contentShape(Rectangle())
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.lineNeutral, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                
                // MARK: - 서비스 섹션
                VStack(spacing: 0) {
                    sectionHeader(title: "서비스")
                    
                    Button {
                        router.push(.accountManage)
                    } label: {
                        HStack {
                            Text("계정 관리")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Spacer()
                            Image(asset: DesignSystemAsset.lineRight)
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 0)
                        .frame(height: 48)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        // 시스템 알림 설정으로 이동
//                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//                            UIApplication.shared.open(settingsUrl)
//                        }
                        router.push(.editAlert)
                    } label: {
                        HStack {
                            Text("알림 설정")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Spacer()
                            Image(asset: DesignSystemAsset.lineRight)
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 0)
                        .frame(height: 48)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                
                // MARK: - 고객센터 섹션
                VStack(spacing: 0) {
                    sectionHeader(title: "고객센터")
                    
                    Button {
                        router.push(.faq)
                    } label: {
                        HStack {
                            Text("FAQ")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Spacer()
                            Image(asset: DesignSystemAsset.lineRight)
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 0)
                        .frame(height: 48)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        router.push(.feedback)
                    } label: {
                        HStack {
                            Text("서비스 피드백")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Spacer()
                            Image(asset: DesignSystemAsset.lineRight)
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 0)
                        .frame(height: 48)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button {
                        router.push(.termsMenu)
                    } label: {
                        HStack {
                            Text("약관 및 정책")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundStyle(Color.captionStrong)
                            Spacer()
                            Image(asset: DesignSystemAsset.lineRight)
                                .foregroundColor(Color.captionNeutral)
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 0)
                        .frame(height: 48)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                Task {
                    userInfo = viewModel.loadUserInfo()
                }
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
