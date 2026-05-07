//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//

import SwiftUI
import DesignSystem
import Shared
import HomeDomain
import PopupView

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var showCalendar = false
    @State private var refreshSpinAngle: Double = 0
    @State private var calendarDisplayedMonth = Date()
    @State private var calendarDataDays: Set<Int> = []
    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection
    @Environment(ExploreIntent.self) private var exploreIntent
    @Environment(AppState.self) private var appState

    private var isGuest: Bool { appState.authState == .guest }

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            if viewModel.homeState == .idle || viewModel.homeState == .loading {
                Spacer()
                ProgressView()
                    .tint(Color.primaryNormal)
                Spacer()
            } else {
                PullToRefreshView(
                    threshold: 120,
                    cooldownInterval: 3.0,
                    content: {
                        dateBarView
                        contentView
                    },
                    animationView: {
                        AnyView(LoadingView())
                    },
                    onRefresh: {
                        await viewModel.refreshToToday()
                    }
                )
            }
        }
        .background(Color.bgSystem.ignoresSafeArea())
        .popup(isPresented: $showCalendar) {
                CalendarPopupView(
                    isPresented: $showCalendar,
                    selectedDate: Binding(
                        get: { viewModel.calendarState.selectedDate },
                        set: { viewModel.calendarState.selectedDate = $0 }
                    ),
                    displayedMonthDate: $calendarDisplayedMonth,
                    dataDays: $calendarDataDays,
                    onDateSelected: { date in
                        viewModel.selectDateWithMonthGuarantee(date)
                    }
                )
                .padding(.horizontal, 24)
        } customize: {
                $0
                  .type(.default)
                  .position(.center)
                  .animation(.easeInOut)
                  .closeOnTap(false)
                  .closeOnTapOutside(true)
                  .allowTapThroughBG(false)
                  .backgroundColor(Color.bgPopupDim.opacity(0.6))
            }
            .navigationBarHidden(true)
            .onAppear {
                calendarDisplayedMonth = viewModel.calendarState.displayedMonth
                calendarDataDays = viewModel.calendarState.dataDays
                if isGuest {
                    viewModel.homeState = .guest
                    return
                }
                Task {
                    if await viewModel.shouldReloadToday() {
                        await viewModel.loadToday()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("RefreshHome"))) { _ in
                if !isGuest {
                    Task { await viewModel.refreshCurrentData() }
                }
            }
            .onChange(of: appState.authState) { _, newValue in
                Task {
                    await viewModel.resetForAuthChange()
                    if newValue == .authenticated {
                        await viewModel.loadToday()
                    }
                }
            }
            .onChange(of: viewModel.calendarState.displayedMonth) { _, newValue in
                if !showCalendar {
                    calendarDisplayedMonth = newValue
                }
            }
            .onChange(of: viewModel.calendarState.dataDays) { _, newValue in
                if !showCalendar {
                    calendarDataDays = newValue
                }
            }
            .onChange(of: calendarDisplayedMonth) { _, newValue in
                guard showCalendar else { return }
                Task {
                    await updateCalendarDataDays(for: newValue)
                }
            }
        }

    // MARK: — 헤더
    private var headerView: some View {
        HStack {
            Image(asset: DesignSystemAsset.logo)
                
            Spacer()

            Button {
                router.push(.search)
            } label: {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
        .background(Color.bgSystem)
    }

    // MARK: — 날짜 바
    private var dateBarView: some View {
        HStack(spacing: 0) {
            Text(viewModel.formattedDate)
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color.captionStrong)
                .padding(.leading, 24)

            Spacer()

            Button(action: {
                let calendar = Calendar.current
                let currentDisplayMonth = viewModel.calendarState.displayedMonth
                let monthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDisplayMonth)) ?? currentDisplayMonth
                
                Task { @MainActor in
                    calendarDisplayedMonth = monthDate
                    calendarDataDays = viewModel.calendarState.dataDays
                    showCalendar = true
                }
                
                Task {
                    await updateCalendarDataDays(for: monthDate)
                }
            }) {
                Image(asset: DesignSystemAsset.lineCalendar)
                    .padding(.trailing, 24)
            }
        }
        .frame(height: 52)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    // MARK: — 본문 컨텐츠
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.homeState {
        case .idle, .loading:
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
                    exploreIntent.selectedTab = 0
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
                    tabSelection.selectedTab = .explore
                    router.resetTo(.tabbar(selectedTab: .explore))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        exploreIntent.day = dayIndex
                        exploreIntent.selectedTab = 1
                        exploreIntent.trigger = UUID()
                    }
                },
                refreshAction: { Task { await viewModel.loadToday() } },
                selectedDate: viewModel.selectedDate
            )
        case .articles:
            articlesSection
                .padding(.bottom, 8)
        }
    }

    // MARK: — 아티클 리스트
    private var articlesSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.top, 20)
                    .padding(.leading, 28)

                Spacer()

                Button(action: {
                    refreshSpinAngle += 360
                    Task { await viewModel.refreshToToday() }
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                            .rotationEffect(.degrees(refreshSpinAngle))
                            .animation(.linear(duration: 0.8), value: refreshSpinAngle)
                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .padding(.top, 23)
                .padding(.trailing, 24)
            }

            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredArticles) { article in
                    ArticleRow(article: article)
                        .frame(height: 88)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task { await viewModel.markArticleAsRead(articleId: article.articleId) }
                            router.push(.articleDetail(id: "\(article.articleId)"))
                        }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }

    private func updateCalendarDataDays(for month: Date) async {
        let days = await viewModel.calendarDataDays(for: month)
        await MainActor.run {
            calendarDataDays = days
        }
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
        default: return 0
        }
    }
}
