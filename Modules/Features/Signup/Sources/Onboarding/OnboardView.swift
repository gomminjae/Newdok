//
//  OnboardView.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//

import SwiftUI
import Auth
import DesignSystem

public struct OnboardingView: View {
    @State private var currentPage = 0
    let totalPages = 3
    
    public init() {}
    
    public var body: some View {
        NavigationView {
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
                        print("회원가입 버튼 클릭")
                    }) {
                        NavigationLink(destination: SignupView()) {
                            Text("회원가입")
                                .font(.hanSansNeo(18, .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#2866D3"))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 31)
                    .frame(height: 58)
                    
                    HStack {
                        Text("이미 계정이 있나요?")
                            .font(.hanSansNeo(14,.medium))
                            .foregroundColor(Color(hex: "#555555"))
                        Button(action: {
                            print("로그인 클릭")
                        }) {
                            NavigationLink(destination: LoginView()) {
                                Text("로그인")
                                    .font(.hanSansNeo(14,.medium))
                                    .foregroundColor(.primaryNormal)
                                    .underline()
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 130)
            }
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let imageName: DesignSystemImages
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        VStack {
            Spacer(minLength: 64)
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(subtitle)
                .font(.hanSansNeo(22, .bold))
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .padding(.top, 12)
            
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .frame(width: currentPage == index ? 32 : 32, height: 6)
                        .foregroundColor(currentPage == index ? .primaryNormal : Color.blue.opacity(0.2))
                }
            }
            .padding(.top, 34)
            
            Image(asset: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)
                .padding()
            
            
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}

