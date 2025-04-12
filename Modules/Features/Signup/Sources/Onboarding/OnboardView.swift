//
//  OnboardView.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//
import SwiftUI
import Auth
import DesignSystem
import Shared
import Combine

public struct OnboardingView: View {

    @State private var currentPage = 0
    let totalPages = 3
    
    @EnvironmentObject private var router: AppRouter

    public init() {
    }

    public var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "너무 많은 뉴스레터 브랜드",
                    subtitle: "일일이 찾아볼 필요 없이\n내게 필요한 뉴스레터만 쏙쏙",
                    imageName: DesignSystemAsset.letter,
                    currentPage: currentPage,
                    totalPages: totalPages
                )
                .tag(0)

                OnboardingPageView(
                    title: "복잡하게 쌓여가는 메일함은 안녕!",
                    subtitle: "다른 메일과 섞이지 않고\n오늘 받은 뉴스레터만 한눈에",
                    imageName: DesignSystemAsset.calendar,
                    currentPage: currentPage,
                    totalPages: totalPages
                )
                .tag(1)

                OnboardingPageView(
                    title: "번거로운 구독 관리도",
                    subtitle: "뉴독에서는 버튼 하나로\n쉽고 빠르게!",
                    imageName: DesignSystemAsset.post,
                    currentPage: currentPage,
                    totalPages: totalPages
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            VStack {
                Button(action: {
                    router.push(.signup)
                }) {
                    Text("회원가입")
                        .font(.hanSansNeo(18, .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#2866D3"))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 31)
                .frame(height: 58)

                HStack {
                    Text("이미 계정이 있나요?")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#555555"))

                    Button(action: {
                        router.push(.login)
                        
                    }) {
                        Text("로그인")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundColor(.primaryNormal)
                            .underline()
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 130)
        }
    }
}

