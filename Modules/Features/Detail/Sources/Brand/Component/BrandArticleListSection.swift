import SwiftUI
import DesignSystem
import DetailDomain
import FoundationKit

struct BrandArticleListSection: View {
    let articles: [DetailBrandArticle]
    let onArticleTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("지난 아티클 보기")
                .font(.hanSansNeo(14, .bold))
                .foregroundStyle(Color.captionNeutral)
                .padding(.leading, 20)
                .padding(.top, 20)

            if articles.isEmpty {
                emptyState
            } else {
                ForEach(articles) { article in
                    articleRow(article)
                        .onTapGesture {
                            onArticleTap("\(article.id)")
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 32)
    }

    private var emptyState: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("아티클을 준비하는 중이에요.")
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color.captionHeavy)
            Text("조금만 기다려 주세요!")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .padding(.top, 20)
    }

    private func articleRow(_ article: DetailBrandArticle) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(article.title)
                .font(.hanSansNeo(14, .bold))
                .foregroundStyle(Color.captionStrong)
                .padding(.bottom, 4)
            HStack {
                Text(article.date.prefix(10))
                    .font(.hanSansNeo(12, .medium))
                    .foregroundColor(Color.captionNeutral)
                Divider()
                Text(extractTime(from: article.date))
                    .font(.hanSansNeo(12, .medium))
                    .foregroundColor(Color.captionNeutral)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.lineNeutral, lineWidth: 1))
        .padding(.horizontal)
    }

    private func extractTime(from isoString: String) -> String {
        guard let date = isoString.newdokISODate else { return "" }
        return date.newdokTimeText
    }
}
