//
//  ArticleRow.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI
import DesignSystem

struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack(spacing: 12) {
            // 🔹 뉴스레터 아이콘
            Image(asset: DesignSystemAsset.signup)//article.imageName)
                .resizable()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.source)
                        .font(.hanSansNeo(12, .regular))
                        .foregroundColor(.gray)

                    Spacer()

                    Text(article.isRead ? "읽음" : "안읽음")
                        .font(.hanSansNeo(11, .regular))
                        .foregroundColor(article.isRead ? .gray : Color.primaryNormal)
                }

                Text(article.title)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.trailing,20)
            }
        }
        .padding(16)
        .background(article.isRead ? Color(hex: "EBEBEB") : Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1) 
    }
}

#Preview {
    ArticleRow(article: Article(
        title: "💰 도커스님의 희망 은퇴 연령은?",
        source: "머니레터",
        imageName: "signup",
        isRead: false
    ))
    .previewLayout(.sizeThatFits)
    .padding()
}
