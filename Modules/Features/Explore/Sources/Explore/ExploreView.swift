import SwiftUI
import DesignSystem
import ExploreDomain
import Shared

public struct ExploreView: View {
    @State private var viewModel: ExploreViewModel
    @State private var currentPage: Int = 0
    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection
    @Environment(AppState.self) private var appState

    private var isGuest: Bool { appState.authState == .guest }

    public init(viewModel: ExploreViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                tabSwitcher
                Divider()

                if isGuest {
                    guestContent
                } else {
                    loggedInContent
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .onChange(of: appState.authState) {
                Task { await viewModel.reloadOnAuthChanged() }
            }
            .onChange(of: tabSelection.exploreTrigger) {
                guard tabSelection.hasPendingExplore else { return }
                applyExploreParams()
                Task { await viewModel.reloadOnTrigger() }
            }
            .onAppear {
                applyExploreParams()
                viewModel.reloadUserInfo()
                Task { await viewModel.loadInitial() }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.reloadUserInfo()
            }
            .serverErrorPopup(
                error: $viewModel.currentError,
                onRetry: {
                    Task { await viewModel.retryLoad() }
                }
            )
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            Text("둘러보기")
                .font(.hanSansNeo(18, .bold))
                .foregroundStyle(Color.captionHeavy)
            Spacer()
            Button {
                router.push(.search)
            } label: {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 12)
            }
            .accessibilityLabel("검색")
            .accessibilityIdentifier("explore_search_button")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
        .background(Color.white)
    }

    // MARK: - Tab Switcher

    private var tabSwitcher: some View {
        VStack(spacing: 0) {
            if isGuest {
                HStack(spacing: 0) {
                    tabButton(title: "모든 뉴스레터", index: 0)
                    tabButton(title: "추천 뉴스레터", index: 1)
                }
                .padding(.top, 16)
            } else {
                HStack(spacing: 0) {
                    tabButton(title: "추천 뉴스레터", index: 0)
                    tabButton(title: "모든 뉴스레터", index: 1)
                }
                .padding(.top, 16)
            }

            GeometryReader { geometry in
                let width = geometry.size.width / 2
                Rectangle()
                    .fill(Color.captionStrong)
                    .frame(width: width, height: 2)
                    .offset(x: viewModel.selectedTab == 0 ? 0 : width)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.selectedTab)
            }
            .frame(height: 2)
        }
    }

    // MARK: - Guest Content

    @ViewBuilder
    private var guestContent: some View {
        if viewModel.selectedTab == 0 {
            allNewsletterSection
        } else {
            ExploreGuestSection(
                onSignup: { router.push(.signup) },
                onLogin: { router.push(.login) }
            )
        }
    }

    // MARK: - Logged-in Content

    @ViewBuilder
    private var loggedInContent: some View {
        if viewModel.selectedTab == 0 {
            if !viewModel.isInitialLoaded {
                EmptyView()
            } else if !viewModel.hasUserProfile {
                ExploreNoProfileSection(
                    nickname: viewModel.nickname,
                    onEditProfile: { router.push(.editProfile) }
                )
            } else {
                ExploreRecommendationSection(
                    nickname: viewModel.nickname,
                    myRecommendation: viewModel.fixedMyRecommendation,
                    unionRecommendation: viewModel.fixedUnionRecommendation,
                    isRefreshing: viewModel.isRefreshingRecommendation,
                    prioritizedInterests: viewModel.prioritizeInterestsForNewsletter,
                    onBrandTap: { id in router.push(.brandDetail(id: "\(id)")) },
                    onRefresh: { Task { await viewModel.fetchRecommendation(forceRefresh: true) } },
                    currentPage: $currentPage
                )
            }
        } else if viewModel.selectedTab == 1 {
            allNewsletterSection
                .background(Color.bgSystem)
        }
    }

    // MARK: - All Newsletters

    private var allNewsletterSection: some View {
        ExploreAllNewsletterSection(
            orderOpt: $viewModel.orderOpt,
            industry: $viewModel.industry,
            day: $viewModel.day,
            isShowSortSheet: $viewModel.isShowSortSheet,
            isShowFilterSheet: $viewModel.isShowFilterSheet,
            shouldScrollToTop: $viewModel.shouldScrollToTop,
            industryText: viewModel.industryText,
            dayText: viewModel.dayText,
            industries: viewModel.industries,
            days: viewModel.days,
            newsletters: viewModel.allNewsletters,
            onSort: {
                await viewModel.handleSort()
            },
            onFilter: {
                await viewModel.handleFilter()
            },
            onReset: {
                await viewModel.handleReset()
            },
            onBrandTap: { id in router.push(.brandDetail(id: "\(id)")) }
        )
    }

    // MARK: - Helpers

    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { viewModel.selectedTab = index }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(viewModel.selectedTab == index ? Color.captionStrong : Color.captionAlternative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .accessibilityLabel(title)
        .accessibilityIdentifier("explore_tab_\(index)")
        .accessibilityAddTraits(viewModel.selectedTab == index ? .isSelected : [])
    }

    private func applyExploreParams() {
        guard tabSelection.hasPendingExplore else { return }
        let params = tabSelection.consumeExploreParams()
        if let day = params.day, viewModel.day != [day] {
            viewModel.day = [day]
        }
        if viewModel.selectedTab != params.tab {
            viewModel.selectedTab = params.tab
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
