//
//  OnboardView.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//
import SwiftUI
import DesignSystem
import Shared


public struct OnboardingView: View {
    @State private var currentPage = 0
    let totalPages = 3

    @Environment(AppRouter.self) private var router

    private let onboardingStorage: OnboardingStorable

    public init(onboardingStorage: OnboardingStorable) {
        self.onboardingStorage = onboardingStorage
    }

    public var body: some View {
        ZStack {
            // 메인 컨텐츠
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                                    OnboardingPageView(
                    title: "너무 많은 뉴스레터 브랜드",
                    subtitle: "일일이 찾아볼 필요 없이\n내게 필요한 뉴스레터만 쏙쏙",
                    imageName: DesignSystemAsset.letter
                )
                .tag(0)

                OnboardingPageView(
                    title: "복잡하게 쌓여가는 메일함은 안녕!",
                    subtitle: "다른 메일과 섞이지 않고\n오늘 받은 뉴스레터만 한눈에",
                    imageName: DesignSystemAsset.calendar
                )
                .tag(1)

                OnboardingPageView(
                    title: "번거로운 구독 관리도",
                    subtitle: "뉴독에서는 버튼 하나로\n쉽고 빠르게!",
                    imageName: DesignSystemAsset.post
                )
                .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                VStack(spacing: 0) {
                    Button(action: {
                        onboardingStorage.markCompleted()
                        router.push(.login)
                    }) {
                        Text("회원가입")
                            .font(.hanSansNeo(14, .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryNormal)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .padding(.horizontal, 31)
                    .frame(height: 48)

                    HStack {
                        Text("이미 계정이 있나요?")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundColor(Color.captionAssistive)

                        Button(action: {
                            onboardingStorage.markCompleted()
                            router.push(.login)
                        }) {
                            Text("로그인")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(.primaryNormal)
                                .underline()
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 56)
                }
            }
            
            // 인디케이터를 z축으로 앞에 배치
            VStack {
//                Spacer()
//                    .frame(height: 186)
//                
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .frame(width: currentPage == index ? 32 : 32, height: 6)
                            .foregroundColor(currentPage == index ? .primaryNormal : Color.blue.opacity(0.2))
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 186)
                
                Spacer()
            }
            .zIndex(1) // z축으로 앞에 배치
        }
    }
}
