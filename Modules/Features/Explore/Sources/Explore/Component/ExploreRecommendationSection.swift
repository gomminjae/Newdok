import SwiftUI
import ExploreDomain
import DesignSystem

struct ExploreRecommendationSection: View {
    let nickname: String
    let myRecommendation: [ExploreNewsletterDetail]
    let unionRecommendation: [ExploreNewsletterDetail]
    let isRefreshing: Bool
    let prioritizedInterests: (ExploreNewsletterDetail) -> [String]
    let onBrandTap: (Int) -> Void
    let onRefresh: () -> Void

    @Binding var currentPage: Int
    @State private var spinAngle: Double = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("\(nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                    .font(.hanSansNeo(20, .bold))
                    .padding(.top, 20)
                    .padding(.horizontal, 24)

                PagingScrollView(
                    newsletters: myRecommendation,
                    currentPage: $currentPage,
                    onItemTap: onBrandTap
                )

                refreshHeader

                LazyVStack(spacing: 12) {
                    ForEach(unionRecommendation, id: \.id) { newsletter in
                        NewsletterRow(
                            newsletter: newsletter,
                            prioritizedInterests: prioritizedInterests(newsletter)
                        )
                        .padding(.horizontal, 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onBrandTap(newsletter.id)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .background(Color.bgSystem)
    }

    private var refreshHeader: some View {
        HStack(spacing: 0) {
            Text("이런 뉴스레터는 어때요?")
                .font(.hanSansNeo(16, .bold))
            Spacer()
            Button(action: {
                spinAngle += 360
                onRefresh()
            }) {
                HStack(spacing: 4) {
                    Image(asset: DesignSystemAsset.lineReload)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(Color.primaryNormal)
                        .rotationEffect(.degrees(spinAngle))
                        .animation(.linear(duration: 0.8), value: spinAngle)
                    Text("새로고침")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.primaryNormal)
                }
            }
            .accessibilityLabel("추천 새로고침")
            .accessibilityIdentifier("explore_recommendation_refresh_button")
            .disabled(isRefreshing)
        }
        .padding(.top, 20)
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
