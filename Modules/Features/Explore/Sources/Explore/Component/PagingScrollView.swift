import SwiftUI
import ExploreDomain

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
