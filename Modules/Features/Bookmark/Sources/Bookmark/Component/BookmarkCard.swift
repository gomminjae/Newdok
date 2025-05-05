//
//  BookmarkCard.swift
//  Bookmark
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import Foundation
import Domain
import DesignSystem
import Kingfisher


struct BookmarkCard: View {
    let article: Bookmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(article.articleTitle)
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(Color(hex: "#363636"))
                .lineLimit(2)
                .padding(.bottom,8)
            
            Text(article.sampleText)
                .font(.hanSansNeo(14, .regular))
                .foregroundColor(Color(hex: "#565656"))
                .lineLimit(2)
                .padding(.bottom,12)
            
            HStack {
                HStack(spacing: 4) {
                    KFImage(URL(string: article.imageURL))
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        //.background(Color.gray)
                    Text(article.brandName)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(article.date)
                    .font(.hanSansNeo(12, .medium))
                    .foregroundColor(Color(hex: "#969696"))
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        )
    }
}
