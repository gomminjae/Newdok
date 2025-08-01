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
import PopupView
import Lottie

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showCalendar = false
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
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
        .onAppear {
            if !isGuest {
                Task { await viewModel.loadToday() }
            }
        }
        .popup(isPresented: $showCalendar) {
            CalendarPopupView(
                isPresented: $showCalendar,
                selectedDate: $viewModel.calendarState.selectedDate,
                displayedMonthDate: $viewModel.calendarState.displayedMonth,
                dataDays: $viewModel.calendarState.dataDays,
                isLoading: $viewModel.calendarState.isLoading,
                onDateSelected: { date in
                    // 새로운 메서드 사용 - 월 보장
                    viewModel.selectDateWithMonthGuarantee(date)
                    showCalendar = false
                },
                onMonthChanged: { monthDate in
                    // 월 변경 시 displayedMonth는 CalendarPopupView에서 자동으로 업데이트됨
                    print("📅 [HomeView] 월 변경: \(monthDate), selectedDate 유지: \(viewModel.selectedDate)")
                    Task { await viewModel.loadArticles(for: monthDate) }
                }
            )
        } customize: { $0.type(.default).position(.center).animation(.easeInOut).closeOnTap(false).backgroundColor(Color.black.opacity(0.3)) }
        .onChange(of: showCalendar) { isShowing in
            if isShowing {
                // 캘린더 팝업이 열릴 때 displayedMonth를 selectedDate로 초기화
                viewModel.displayedMonth = viewModel.selectedDate
                print("📅 [HomeView] 캘린더 팝업 열림 - 선택된 날짜: \(viewModel.selectedDate), 표시 월: \(viewModel.displayedMonth)")
                // 현재 표시된 월의 데이터를 새로고침
                Task { 
                    await viewModel.loadCalendarData(for: viewModel.displayedMonth)
                }
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
                Button(action: { router.push(.search) }) {
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
            Button(action: {
                Task {
                    // 현재 표시된 월의 데이터를 로드
                    await viewModel.loadCalendarData(for: viewModel.displayedMonth)
                    showCalendar.toggle()
                }
            }) {
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
                    loginAction: { router.push(.login) },
                    refreshAction: { Task { await viewModel.loadToday() } }
                )
            case .noSubscriptions:
                NoDataView(
                    type: .noSubscriptions, 
                    buttonAction: {
                        exploreIntent.selectedTab = 0 // 추천 뉴스레터 탭으로 설정
                        exploreIntent.trigger = UUID()
                        router.resetTo(.tabbar(selectedTab: .explore))
                        tabSelection.selectedTab = .explore
                    },
                    refreshAction: { Task { await viewModel.loadToday() } }
                )
            case .noArticles:
                NoDataView(
                    type: .noArticles, 
                    buttonAction: {
                        let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                        let dayIndex = convertWeekdayToExploreIndex(weekday)
                        exploreIntent.day = dayIndex
                        exploreIntent.selectedTab = 1
                        exploreIntent.trigger = UUID()
                        router.resetTo(.tabbar(selectedTab: .explore))
                        tabSelection.selectedTab = .explore
                    },
                    refreshAction: { Task { await viewModel.loadToday() } }
                )
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

    private func convertWeekdayToExploreIndex(_ weekday: Int) -> Int {
        switch weekday {
        case 1: return 7
        case 2: return 1 
        case 3: return 2
        case 4: return 3
        case 5: return 4
        case 6: return 5
        case 7: return 6
        default: return 8
        }
    }
}
