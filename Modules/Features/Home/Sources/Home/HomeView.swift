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
            
            VStack(spacing: 0) {
                // MARK: - 헤더
                HStack {
                    Image(asset: DesignSystemAsset.logo)
                        .resizable()
                        .frame(width: 126, height: 24)
                        .padding(.vertical, 18)
                        .padding(.leading, 20)
                    Spacer()
                    HStack(spacing: 16) {
                        Button(action: { print("검색") }) {
                            Image(asset: DesignSystemAsset.lineSearch)
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.vertical, 18)
                        }
                        Button(action: { print("알람") }) {
                            Image(asset: DesignSystemAsset.lineBell)
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.vertical, 18)
                                .padding(.trailing, 17.8)
                        }
                    }
                }
                .background(Color(hex: "#F5F5F7"))
                
                ScrollView {
                    // MARK: - 날짜 + 캘린더 버튼
                    HStack(spacing: 0) {
                        Text(viewModel.formattedDate)
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color(hex: "#363636"))
                        
                            .padding(.leading, 24)
                        
                        Spacer()
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Image(asset: DesignSystemAsset.lineCalendar)
                            
                                .padding(.trailing, 24)
                        }
                    }
                    .frame(height: 52)
                    .background(
                        Color.white
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    )
                    .padding(.top, 8)
                    //.padding(.horizontal, 8)
                    
                    
                    // MARK: - 콘텐츠 뷰
                    VStack {
                        if isGuest {
                            NoDataView(type: .requireSignUp, buttonAction: {
                                router.push(.signup)
                            }, loginAction: {
                                router.resetTo(.login)
                            })
                        } else {
                            if viewModel.subscribedNewsletters.isEmpty && viewModel.filteredArticles.isEmpty {
                                NoDataView(type: .noSubscriptions, buttonAction: {})
                            } else if viewModel.filteredArticles.isEmpty {
                                NoDataView(type: .noArticles, buttonAction: {})
                            } else {
                                VStack {
                                    HStack {
                                        Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
                                            .font(.hanSansNeo(18, .bold))
                                            .padding(.top, 20)
                                            .padding(.leading, 28)
                                        Spacer()
                                        Button(action: {
                                            Task {
                                                await viewModel.loadToday()
                                            }
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(asset: DesignSystemAsset.refresh)
                                                    .font(.hanSansNeo(14,.medium))
                                                    .foregroundStyle(Color.primaryNormal)
                                                Text("새로고침")
                                                    .font(.hanSansNeo(14, .medium))
                                                    .foregroundStyle(Color.primaryNormal)
                                            }
                                        }
                                        .padding(.top, 23)
                                        .padding(.trailing, 24)
                                    }
                                    
                                    VStack(spacing: 8) {
                                        ForEach(viewModel.filteredArticles) { article in
                                            ArticleRow(article: article)
                                                .frame(height: 88)
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 16)
                                }
                                .background(
                                    Color.white
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                )
                            }
                        }
                    }
                }
                .background(Color(hex: "#F5F5F7"))
                

            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .popup(isPresented: $showCalendar) {
            CalendarPopupView(
                isPresented: $showCalendar,
                onDateSelected: { date in
                    viewModel.selectedDate = date
                    viewModel.loadArticles(for: date)
                }
            )
        }
        .onAppear {
            Task {
                await viewModel.loadToday()
            }
        }
    }
}


