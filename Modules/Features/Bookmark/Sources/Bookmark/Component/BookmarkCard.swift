//
//  BookmarkCard.swift
//  Bookmark
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import Foundation
import BookmarkDomain
import DesignSystem
import Kingfisher

struct BookmarkCard: View {
    let article: BookmarkItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(article.articleTitle)
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(Color.captionStrong)
                .lineLimit(2)
                .padding(.bottom, 8)
            
            Text(article.sampleText)
                .font(.hanSansNeo(14, .regular))
                .foregroundColor(Color.captionNeutral)
                .lineLimit(2)
                .padding(.bottom, 12)
            
            HStack {
                HStack(spacing: 4) {
                    KFImage(URL(string: article.imageURL))
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 40 * UIScreen.main.scale, height: 40 * UIScreen.main.scale)))
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color.lineNeutral)
                        }
                    Text(article.brandName)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
                Text(article.date.prefix(10))
                    .font(.hanSansNeo(12, .medium))
                    .foregroundColor(Color.captionAssistive)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.lineNeutral, lineWidth: 1)
        )
    }
}
