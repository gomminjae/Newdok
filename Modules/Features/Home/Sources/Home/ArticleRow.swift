//
//  ArticleRow.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI
import DesignSystem
import HomeDomain
import Kingfisher

struct ArticleRow: View {
    let article: HomeArticle
    let highlightCount: Int

    @Environment(\.displayScale) private var displayScale
    init(article: HomeArticle, highlightCount: Int = 0) {
        self.article = article
        self.highlightCount = highlightCount
    }

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: article.imageUrl))
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 56 * displayScale, height: 56 * displayScale)))
                .placeholder {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 56, height: 56)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.brandName)
                        .font(.hanSansNeo(11, .medium))
                        .foregroundColor(Color.captionNeutral)

                    Spacer()

                    if highlightCount > 0 {
                        highlightBadge
                    } else {
                        Text(article.status == "Read" ? "읽음" : "안읽음")
                            .font(.hanSansNeo(11, .medium))
                            .foregroundColor(article.status == "Read" ? Color.captionAlternative : Color.primaryNormal)
                    }
                }

                Text(article.articleTitle)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionStrong)
                    .lineLimit(1)
                    .padding(.trailing, 20)
            }
        }
        .padding(16)
        .background(article.status == "Read" ? Color.lineNeutral : Color.bgNormal)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineNeutral, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(article.brandName), \(article.articleTitle), \(article.status == "Read" ? "읽음" : "안읽음")\(highlightCount > 0 ? ", 하이라이트 \(highlightCount)개" : "")")
        .accessibilityIdentifier("home_article_\(article.articleId)")
    }

    private var highlightBadge: some View {
        HStack(spacing: 4) {
            Image(asset: DesignSystemAsset.pen)
                .renderingMode(.template)
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.white)
            Text("\(highlightCount)")
                .font(.hanSansNeo(11, .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.primaryMuted)
        .clipShape(Capsule())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    ArticleRow(article: HomeArticle(brandName: "네오", imageUrl: "", articleTitle: "헬로", articleId: 3, status: "Read"
    ))
    .padding()
}
