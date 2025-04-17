//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
import SwiftUI
import DesignSystem
import Shared
import Domain

public struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel
    
    @State private var showCalendar = false
    
    @EnvironmentObject private var router: AppRouter
    @AppStorage("isGuest") private var isGuest: Bool = false
    
    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            Color(hex: "F5F5F7")
                .ignoresSafeArea()
            
            PullToRefreshView {
                VStack(spacing: 0) {
                    HStack {
                        Image(asset: DesignSystemAsset.logo)
                            .resizable()
                            .frame(width: 126, height: 24)
                            .padding(.vertical, 18)
                            .padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            print("검색")
                        }) {
                            Image(asset: DesignSystemAsset.search)
                                .padding(.vertical, 18)
                                .padding(.trailing, 2.4)
                        }
                        Button(action: {
                            print("알람")
                        }) {
                            Image(asset: DesignSystemAsset.bell)
                                .padding(.vertical, 18)
                                .padding(.leading, 16)
                                .padding(.trailing, 17.8)
                        }
                    }
                    
                    HStack {
                        Text("5월 23일(수)")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color(hex: "#363636"))
                            .padding(.vertical, 15)
                            .padding(.leading, 24)
                        
                        Spacer()
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Image(asset: DesignSystemAsset.lineCalendar)
                                .padding(.vertical, 15)
                                .padding(.trailing, 24)
                        }
                    }
                    
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.top, 16)
                    .padding(.horizontal, 8)
                    
                    
                    VStack {
                        if isGuest {
                            NoDataView(type: .requireSignUp, buttonAction: {
                                router.push(.signup)
                            }, loginAction: {
                                router.resetTo(.login)
                            })
                        }
                        
                        else {
                            if viewModel.articles.isEmpty {
                                NoDataView(type: .noArticles, buttonAction: {})
                            } else {
                                HStack {
                                    Text("\(viewModel.articles.count)개의 아티클이 도착했어요.")
                                        .font(.hanSansNeo(18, .bold))
                                        .padding(.top, 20)
                                        .padding(.leading, 28)
                                    Spacer()
                                    Button(action: {
                                        print("새로고침 버튼")
                                    }) {
                                        HStack(spacing: 4) {
                                            Image("refresh")
                                            Text("새로고침")
                                                .font(.hanSansNeo(14, .medium))
                                                .foregroundStyle(Color.primaryNormal)
                                        }
                                    }
                                    .padding(.top, 23)
                                    .padding(.trailing, 24)
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(viewModel.articles) { article in
                                        ArticleRow(article: article)
                                            .frame(height: 88)
                                    }
                                }
                                //.background(Color.red)
                                .padding(.top,20)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    
                    Spacer()
                }
            } onRefresh: {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                
            }
            .navigationBarHidden(true)
            .popup(isPresented: $showCalendar) {
                CalendarPopupView(isPresented: $showCalendar)
            }
        }
    }
}


import SwiftUI

struct PullToRefreshView<Content: View>: View {
    let content: () -> Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullProgress: CGFloat = 0
    
    private let threshold: CGFloat = 80
    
    var body: some View {
        GeometryReader { outerProxy in
            ScrollView(showsIndicators: false) {
                // 스크롤 offset 계산용
                GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let offset = proxy.frame(in: .named("PullToRefresh")).minY
                        
                        if offset > 0 {
                            
                            pullProgress = min(1.0, offset / threshold)
                            
                            if !isRefreshing && offset > threshold {
                                isRefreshing = true
                                Task {
                                    await onRefresh()
                                    
                                    withAnimation {
                                        isRefreshing = false
                                        pullProgress = 0
                                    }
                                }
                            }
                        } else {
                            
                            if !isRefreshing {
                                pullProgress = 0
                            }
                        }
                    }
                    return Color.clear
                }
                .frame(height: 0)
                
                if isRefreshing || pullProgress > 0 {
                    CustomSpinner(progress: pullProgress, isRefreshing: isRefreshing)
                        .frame(height: 60)
                }
                
                
                content()
                    .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: "PullToRefresh")
        }
    }
}
struct CustomSpinner: View {
    let progress: CGFloat
    let isRefreshing: Bool
    
    private let circleCount = 5
    
    var body: some View {
        
        HStack(spacing: 12) {
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .fill(gradient(for: index))
                    .frame(width: 20, height: 20)
                    .scaleEffect(scale(for: index))
                    .opacity(opacity(for: index))
            }
        }
        .padding(.top, 8)
        .animation(.easeInOut, value: progress)
        .animation(.easeInOut, value: isRefreshing)
    }
    
    private func gradient(for index: Int) -> LinearGradient {
        let start = Color.blue.opacity(0.3 + 0.1 * Double(index))
        let end   = Color.blue.opacity(0.7 + 0.05 * Double(index))
        return LinearGradient(
            gradient: Gradient(colors: [start, end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func scale(for index: Int) -> CGFloat {
        if isRefreshing {
            return 1.0
        } else {
            return 0.5 + 0.5 * progress
        }
    }
    
    
    private func opacity(for index: Int) -> CGFloat {
        if isRefreshing {
            return 1.0
        } else {
            return 0.5 + 0.5 * progress
        }
    }
}
