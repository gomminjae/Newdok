//
//  ArticleRow.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI
import DesignSystem
import Domain
import Kingfisher

struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: article.imageUrl))
                .placeholder {
                    // 로딩 중 표시
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 56, height: 56)
                }
                .onFailure { error in
                }
                .onSuccess { result in
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
                        .foregroundColor(Color(hex: "#565656"))

                    Spacer()

                    Text(article.status == "Read" ? "읽음" : "안읽음")
                        .font(.hanSansNeo(11, .medium))
                        .foregroundColor(article.status == "Read" ? Color(hex: "#767676") : Color.primaryNormal)
                }

                Text(article.articleTitle)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#363636"))
                    .lineLimit(1)
                    .padding(.trailing,20)
            }
        }
        .padding(16)
        .background(article.status == "Read" ? Color(hex: "EBEBEB") : Color(hex: "#FFFFFF"))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1) 
    }
}

#Preview {
    ArticleRow(article: Article(brandName: "네오", imageUrl: "", articleTitle: "헬로", articleId: 3, status: "Read"
    ))
    .previewLayout(.sizeThatFits)
    .padding()
}
