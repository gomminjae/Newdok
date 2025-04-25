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
        VStack(alignment: .leading, spacing: 0) {
            KFImage(URL(string: recommendation.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(height: 210) // **너비를 직접 정하지 않음!**
                .clipped()
                .cornerRadius(8)

            Text(recommendation.brandName)
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Text(recommendation.firstDescription)
                .font(.hanSansNeo(14, .medium))
                .padding(.top, 8)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(recommendation.interests) { interest in
                        TagView(text: interest.name)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 17)
            .padding(.bottom, 16)
        }
        .background(Color.white)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"))
        }
    }
}
//
//#Preview {
//    RecommendedNewsLetterView()
//}

struct TagView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.hanSansNeo(12))
            .foregroundStyle(Color(hex: "#363636"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
            )
    }
}
