import SwiftUI
import ExploreDomain
import DesignSystem

struct ExploreAllNewsletterSection: View {
    @Binding var orderOpt: ExploreOrderOption
    @Binding var industry: [Int]?
    @Binding var day: [Int]?
    @Binding var isShowSortSheet: Bool
    @Binding var isShowFilterSheet: Bool
    @Binding var shouldScrollToTop: Bool

    let industryText: String
    let dayText: String
    let industries: [SelectableItem]
    let days: [SelectableItem]
    let newsletters: [ExploreBrand]
    let onSort: () async -> Void
    let onFilter: () async -> Void
    let onReset: () async -> Void
    let onBrandTap: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ExploreFilterSection(
                    orderOpt: $orderOpt,
                    industry: $industry,
                    day: $day,
                    isShowSortSheet: $isShowSortSheet,
                    isShowFilterSheet: $isShowFilterSheet,
                    industryText: industryText,
                    dayText: dayText,
                    industries: industries,
                    days: days,
                    onSort: onSort,
                    onFilter: onFilter,
                    onReset: onReset
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

                        ForEach(newsletters) { brand in
                            NewsletterDetailRow(brand: brand)
                                .padding(.horizontal, 20)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onBrandTap(brand.id)
                                }
                        }
                    }
                    .padding(.bottom, 80)
                }
                .onChange(of: shouldScrollToTop) { _, shouldScroll in
                    if shouldScroll {
                        Task {
                            try await Task.sleep(for: .seconds(0.1))
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                            try await Task.sleep(for: .seconds(0.6))
                            shouldScrollToTop = false
                        }
                    }
                }
            }
        }
    }
}
