//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
//import SwiftUI
//import DesignSystem
//import Shared
//import Domain
//
//
//public struct HomeView: View {
//    
//    @StateObject private var viewModel: HomeViewModel
//    @State private var showCalendar = false
//    
//    @EnvironmentObject private var router: AppRouter
//    @AppStorage("isGuest") private var isGuest: Bool = false
//    
//    public init(viewModel: HomeViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//    
//    public var body: some View {
//        ZStack {
//            Color(hex: "F5F5F7")
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // MARK: - 헤더
//                HStack {
//                    Image(asset: DesignSystemAsset.logo)
//                        .resizable()
//                        .frame(width: 126, height: 24)
//                        .padding(.vertical, 18)
//                        .padding(.leading, 20)
//                    Spacer()
//                    HStack(spacing: 16) {
//                        Button(action: { print("검색") }) {
//                            Image(asset: DesignSystemAsset.lineSearch)
//                                .resizable()
//                                .frame(width: 28, height: 28)
//                                .padding(.vertical, 18)
//                        }
//                        Button(action: { print("알람") }) {
//                            Image(asset: DesignSystemAsset.lineBell)
//                                .resizable()
//                                .frame(width: 28, height: 28)
//                                .padding(.vertical, 18)
//                                .padding(.trailing, 17.8)
//                        }
//                    }
//                }
//                .background(Color(hex: "#F5F5F7"))
//                
//                ScrollView {
//                    // MARK: - 날짜 + 캘린더 버튼
//                    HStack(spacing: 0) {
//                        Text(viewModel.formattedDate)
//                            .font(.hanSansNeo(16, .bold))
//                            .foregroundStyle(Color(hex: "#363636"))
//                        
//                            .padding(.leading, 24)
//                        
//                        Spacer()
//                        Button(action: {
//                            showCalendar.toggle()
//                        }) {
//                            Image(asset: DesignSystemAsset.lineCalendar)
//                            
//                                .padding(.trailing, 24)
//                        }
//                    }
//                    .frame(height: 52)
//                    .background(
//                        Color.white
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    )
//                    .padding(.top, 8)
//                    //.padding(.horizontal, 8)
//                    
//                    
//                    // MARK: - 콘텐츠 뷰
//                    VStack {
//                        switch viewModel.homeState {
//                        case .none:
//                            EmptyView()
//                        case .guest:
//                            NoDataView(
//                                type: .requireSignUp,
//                                buttonAction: { router.push(.signup) },
//                                loginAction: { router.push(.login) }
//                            )
//                            
//                        case .noSubscriptions:
//                            NoDataView(type: .noSubscriptions, buttonAction: {})
//
//                        case .noArticles:
//                            NoDataView(type: .noArticles, buttonAction: {})
//
//                        case .articles:
//                            VStack {
//                                HStack {
//                                    Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
//                                        .font(.hanSansNeo(18, .bold))
//                                        .padding(.top, 20)
//                                        .padding(.leading, 28)
//                                    Spacer()
//                                    Button(action: {
//                                        Task {
//                                            await viewModel.loadToday()
//                                        }
//                                    }) {
//                                        HStack(spacing: 4) {
//                                            Image(asset: DesignSystemAsset.refresh)
//                                                .font(.hanSansNeo(14, .medium))
//                                                .foregroundStyle(Color.primaryNormal)
//                                            Text("새로고침")
//                                                .font(.hanSansNeo(14, .medium))
//                                                .foregroundStyle(Color.primaryNormal)
//                                        }
//                                    }
//                                    .padding(.top, 23)
//                                    .padding(.trailing, 24)
//                                }
//
//                                VStack(spacing: 8) {
//                                    ForEach(viewModel.filteredArticles) { article in
//                                        ArticleRow(article: article)
//                                            .frame(height: 88)
//                                            .onTapGesture {
//                                                router.push(.articleDetail(id: article.articleId))
//                                            }
//                                    }
//                                }
//                                .padding(.top, 20)
//                                .padding(.horizontal, 20)
//                                .padding(.bottom, 16)
//                            }
//                            .background(
//                                Color.white
//                                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                            )
//                        }
//                    }
//                }
//                .background(Color(hex: "#F5F5F7"))
//                
//
//            }
//            .background(Color.white)
//            .cornerRadius(12)
//            .padding(.horizontal, 8)
//            .padding(.top, 8)
//        }
//        .navigationBarHidden(true)
//        .fullScreenCover(isPresented: $showCalendar) {
//            CalendarPopupView(
//                isPresented: $showCalendar,
//                onDateSelected: { date in
//                    Task {
//                        viewModel.selectedDate = date
//                        await viewModel.loadArticles(for: date)
//                    }
//                }
//            )
//            .presentationBackground(Color(hex: "#25242C").opacity(0.6))
//        }
//        .onAppear {
//            if !isGuest {
//                Task {
//                    await viewModel.loadToday()
//                }
//            }
//        }
//    }
//}
//
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
            Color(hex: "F5F5F7").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    dateBarView
                    contentView
                }
                .background(Color(hex: "#F5F5F7"))
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCalendar) {
            CalendarPopupView(
                isPresented: $showCalendar,
                onDateSelected: { date in
                    Task {
                        viewModel.selectedDate = date
                        await viewModel.loadArticles(for: date)
                    }
                }
            )
            .presentationBackground(Color(hex: "#25242C").opacity(0.6))
        }
        .onAppear {
            if !isGuest {
                Task { await viewModel.loadToday() }
            }
        }
    }

    private var headerView: some View {
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
    }

    private var dateBarView: some View {
        HStack(spacing: 0) {
            Text(viewModel.formattedDate)
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "#363636"))
                .padding(.leading, 24)
            Spacer()
            Button(action: { showCalendar.toggle() }) {
                Image(asset: DesignSystemAsset.lineCalendar)
                    .padding(.trailing, 24)
            }
        }
        .frame(height: 52)
        .background(
            Color.white.clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.top, 8)
    }

    @ViewBuilder
    private var contentView: some View {
        VStack {
            switch viewModel.homeState {
            case .none:
                EmptyView()
            case .guest:
                NoDataView(
                    type: .requireSignUp,
                    buttonAction: { router.push(.signup) },
                    loginAction: { router.push(.login) }
                )
            case .noSubscriptions:
                NoDataView(type: .noSubscriptions, buttonAction: {})
            case .noArticles:
                NoDataView(type: .noArticles, buttonAction: {})
            case .articles:
                articlesSection
            }
        }
    }

    private var articlesSection: some View {
        VStack {
            HStack {
                Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.top, 20)
                    .padding(.leading, 28)
                Spacer()
                Button(action: {
                    Task { await viewModel.loadToday() }
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .font(.hanSansNeo(14, .medium))
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
                        .onTapGesture {
                            router.push(.articleDetail(id: "\(article.articleId)"))
                        }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            Color.white.clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }
}
