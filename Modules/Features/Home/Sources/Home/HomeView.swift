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
    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection
    @Environment(AppState.self) private var appState

    private var isGuest: Bool { appState.authState == .guest }

    public init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        @Bindable var viewModel = viewModel
        return VStack(spacing: 0) {
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
                        LoadingView()
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
                    selectedDate: $viewModel.calendarState.selectedDate,
                    displayedMonthDate: $viewModel.calendarState.displayedMonth,
                    dataDays: $viewModel.calendarState.dataDays,
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
            .serverErrorPopup(
                error: $viewModel.currentError,
                onRetry: { Task { await viewModel.loadToday() } }
            )
            .onAppear {
                if isGuest {
                    viewModel.homeState = .guest
                    return
                }
                Task {
                    if await viewModel.shouldReloadToday() {
                        await viewModel.loadToday()
                    }
                    await viewModel.refreshHighlights()
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
            .accessibilityLabel("검색")
            .accessibilityIdentifier("home_search_button")
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
                viewModel.applyDataDaysForMonth(viewModel.calendarState.displayedMonth)
                showCalendar = true
            }) {
                Image(asset: DesignSystemAsset.lineCalendar)
                    .padding(.trailing, 24)
            }
            .accessibilityLabel("캘린더")
            .accessibilityIdentifier("home_calendar_button")
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
                buttonAction: { router.push(.login) },
                loginAction: { router.push(.login) },
                refreshAction: { Task { await viewModel.loadToday() } }
            )
        case .noSubscriptions:
            NoDataView(
                type: .noSubscriptions,
                buttonAction: {
                    tabSelection.moveToExplore(tab: 0)
                    router.resetTo(.tabbar(selectedTab: .explore))
                },
                refreshAction: { Task { await viewModel.loadToday() } }
            )
        case .noArticles:
            NoDataView(
                type: .noArticles,
                buttonAction: {
                    let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                    let dayIndex = convertWeekdayToExploreIndex(weekday)
                    tabSelection.moveToExplore(day: dayIndex, tab: 1)
                    router.resetTo(.tabbar(selectedTab: .explore))
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
                .accessibilityLabel("새로고침")
                .accessibilityIdentifier("home_refresh_button")
                .padding(.top, 23)
                .padding(.trailing, 24)
            }

            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredArticles) { article in
                    ArticleRow(article: article, highlightCount: article.highlightCount)
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
