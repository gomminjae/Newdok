import SwiftUI
import DesignSystem
import ExploreDomain
import Shared

public struct ExploreView: View {
    @State private var viewModel: ExploreViewModel
    @State private var currentPage: Int = 0
    @State private var recommendationSpinAngle: Double = 0
    @State private var isLoaded: Bool = false
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
                    Group {
                        if viewModel.selectedTab == 0 {
                            allNewsletterSection
                        } else {
                            ExploreGuestSection(
                                onSignup: { router.push(.signup) },
                                onLogin: { router.push(.login) }
                            )
                        }
                    }
                } else {
                    Group {
                        if viewModel.selectedTab == 0 {
                            if !isLoaded {
                                EmptyView()
                            } else if !viewModel.hasUserProfile {
                                ExploreNoProfileSection(
                                    nickname: viewModel.nickname,
                                    onEditProfile: { router.push(.editProfile) }
                                )
                            } else {
                                ScrollView(showsIndicators: false) {
                                    recommendationSection
                                }
                                .background(Color.bgSystem)
                            }
                        } else if viewModel.selectedTab == 1 {
                            allNewsletterSection
                                .background(Color.bgSystem)
                        }
                    }
                    .padding(.bottom, 0)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .onChange(of: appState.authState) {
                viewModel.clearData()
                viewModel.reloadUserInfo()
                Task {
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                    } else {
                        await viewModel.fetchRecommendation()
                        await viewModel.fetchAllNewsletters()
                    }
                    isLoaded = true
                }
            }
            .onChange(of: tabSelection.exploreTrigger) {
                guard tabSelection.hasPendingExplore else { return }
                applyExploreParams()
                Task {
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                    } else {
                        await viewModel.fetchRecommendation()
                        await viewModel.fetchAllNewsletters()
                    }
                }
            }
            .onAppear {
                applyExploreParams()
                viewModel.reloadUserInfo()
                Task {
                    if isGuest {
                        await viewModel.fetchGuestAllNewsletters()
                        isLoaded = true
                    } else {
                        await viewModel.fetchRecommendation()
                        isLoaded = true
                        await viewModel.fetchAllNewsletters()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.reloadUserInfo()
            }
            .serverErrorPopup(
                error: $viewModel.currentError,
                onRetry: {
                    Task {
                        if isGuest {
                            await viewModel.fetchGuestAllNewsletters()
                        } else {
                            await viewModel.fetchRecommendation()
                            await viewModel.fetchAllNewsletters()
                        }
                    }
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

    // MARK: - Recommendation

    private var recommendationSection: some View {
        VStack(alignment: .leading) {
            Text("\(viewModel.nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 20)
                .padding(.horizontal, 24)

            PagingScrollView(newsletters: viewModel.fixedMyRecommendation, currentPage: $currentPage) { id in
                        router.push(.brandDetail(id: "\(id)"))
                    }

            HStack(spacing: 0) {
                Text("이런 뉴스레터는 어때요?")
                    .font(.hanSansNeo(16, .bold))
                Spacer()
                Button(action: {
                    recommendationSpinAngle += 360
                    Task { await viewModel.fetchRecommendation(forceRefresh: true) }
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .font(.hanSansNeo(14, .bold))
                            .foregroundStyle(Color.primaryNormal)
                            .rotationEffect(.degrees(recommendationSpinAngle))
                            .animation(.linear(duration: 0.8), value: recommendationSpinAngle)
                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .accessibilityLabel("추천 새로고침")
                .accessibilityIdentifier("explore_recommendation_refresh_button")
                .disabled(viewModel.isRefreshingRecommendation)
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            LazyVStack(spacing: 12) {
                ForEach(viewModel.fixedUnionRecommendation, id: \.id) { newsletter in
                    NewsletterRow(
                        newsletter: newsletter,
                        prioritizedInterests: viewModel.prioritizeInterestsForNewsletter(newsletter)
                    )
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.push(.brandDetail(id: "\(newsletter.id)"))
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }

    // MARK: - All Newsletters

    private var allNewsletterSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ExploreFilterSection(
                    orderOpt: $viewModel.orderOpt,
                    industry: $viewModel.industry,
                    day: $viewModel.day,
                    isShowSortSheet: $viewModel.isShowSortSheet,
                    isShowFilterSheet: $viewModel.isShowFilterSheet,
                    industryText: viewModel.industryText,
                    dayText: viewModel.dayText,
                    industries: viewModel.industries,
                    days: viewModel.days,
                    onSort: {
                        viewModel.shouldScrollToTop = true
                        if isGuest {
                            await viewModel.fetchGuestAllNewsletters()
                        } else {
                            await viewModel.fetchAllNewsletters()
                        }
                    },
                    onFilter: {
                        viewModel.shouldScrollToTop = true
                        if isGuest {
                            await viewModel.fetchGuestAllNewsletters()
                        } else {
                            await viewModel.fetchAllNewsletters()
                        }
                    },
                    onReset: {
                        await viewModel.resetFilters()
                        if isGuest {
                            await viewModel.fetchGuestAllNewsletters()
                        } else {
                            await viewModel.fetchAllNewsletters()
                        }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .zIndex(1)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        Color.clear
                            .frame(height: 1)
                            .id("top")

                        ForEach(viewModel.allNewsletters) { brand in
                            NewsletterDetailRow(brand: brand)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    router.push(.brandDetail(id: "\(brand.id)"))
                                }
                        }
                    }
                    .padding(.bottom, 80)
                }
                .onChange(of: viewModel.shouldScrollToTop) { _, shouldScroll in
                    if shouldScroll {
                        Task {
                            try await Task.sleep(for: .seconds(0.1))
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                            try await Task.sleep(for: .seconds(0.6))
                            viewModel.shouldScrollToTop = false
                        }
                    }
                }
            }
        }
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

struct PagingScrollView: View {
    private let items: [ExploreNewsletterDetail]
    @Binding var currentPage: Int
    let onItemTap: (Int) -> Void

    @State private var scrollID: Int?
    @State private var dynamicItems: [ExploreNewsletterDetail] = []

    private let itemWidth: CGFloat = 320
    private let itemHeight: CGFloat = 350
    private let itemSpacing: CGFloat = 12
    private let leadingMargin: CGFloat = 24

    init(newsletters: [ExploreNewsletterDetail], currentPage: Binding<Int>, onItemTap: @escaping (Int) -> Void) {
        self._currentPage = currentPage
        self.items = newsletters
        self.onItemTap = onItemTap
    }

    private func checkAndExpandItems() {
        guard !items.isEmpty else { return }
        let threshold = dynamicItems.count - 10
        if currentPage >= threshold {
            Task { dynamicItems.append(contentsOf: items) }
        }
    }

    private func resetCarouselItems() {
        guard !items.isEmpty else {
            dynamicItems = []
            scrollID = nil
            currentPage = 0
            return
        }
        dynamicItems = items + items + items
        scrollID = 0
        currentPage = 0
    }

    var body: some View {
        GeometryReader { geo in
            let trailingSpace = max(0, geo.size.width - itemWidth - leadingMargin + 12)

            VStack(spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: itemSpacing) {
                        ForEach(dynamicItems.indices, id: \.self) { index in
                            let newsletter = dynamicItems[index]
                            RecommendedNewsLetterView(recommendation: newsletter)
                                .frame(width: itemWidth, height: itemHeight)
                                .id(index)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onItemTap(newsletter.id)
                                }
                        }
                        Color.clear.frame(width: trailingSpace)
                    }
                    .padding(.leading, leadingMargin)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollID)
                .onChange(of: scrollID) { _, newValue in
                    currentPage = newValue ?? 0
                    checkAndExpandItems()
                }
                .onAppear {
                    resetCarouselItems()
                    if scrollID == nil { scrollID = 0 }
                }
                .onChange(of: items.map(\.id)) { _, _ in
                    resetCarouselItems()
                }
                .frame(height: itemHeight)

                let indicatorCount = min(5, items.count)
                if indicatorCount > 0 {
                    HStack(spacing: 6) {
                        ForEach(0..<indicatorCount, id: \.self) { idx in
                            Circle()
                                .fill(idx == (currentPage % indicatorCount)
                                      ? Color.primaryNormal
                                      : Color.primaryBgMuted)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(width: geo.size.width)
        }
        .frame(height: itemHeight + 60)
    }
}
