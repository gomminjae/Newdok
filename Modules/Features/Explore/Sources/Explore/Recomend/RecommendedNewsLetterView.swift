//
//  NewsLetterView.swift
//  Newdok
//
//  Created by 권민재 on 3/2/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain
import Kingfisher

struct RecommendedNewsLetterView: View {
    var recommendation: NewsletterDetail

    var body: some View {
        VStack(spacing: 0) {
            KFImage(URL(string: recommendation.imageUrl ?? ""))
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 640 * UIScreen.main.scale, height: 420 * UIScreen.main.scale)))
                .resizable()
                .scaledToFill()
                .frame(height: 210)
                .clipped()
                .cornerRadius(12)
            
            Divider()

            VStack(alignment: .leading, spacing: 0) {
                Text(recommendation.brandName)
                    .font(.hanSansNeo(16, .bold))
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .foregroundStyle(Color.captionHeavy)

                Text(recommendation.firstDescription)
                    .font(.hanSansNeo(14, .medium))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(height: 40, alignment: .top)
                    .padding(.bottom, 12)
                    .foregroundStyle(Color.captionNeutral)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(recommendation.interests.prefix(3)) { interest in
                            TagView(text: interest.name)
                        }
                    }
                }
                .frame(height: 28)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(width: 320, height: 350)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineNeutral, lineWidth: 1)
        )
    }
}

struct TagView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.hanSansNeo(12))
            .foregroundStyle(Color.captionStrong)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.lineNeutral, lineWidth: 1)
            )
    }
}
