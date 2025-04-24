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
    
    public var recommendation: NewsletterDetail
    
    var body: some View {
        VStack(alignment: .leading) {
            KFImage(URL(string: recommendation.imageUrl))
                .resizable()
                .frame(height: 210)
                .frame(width: 340)

            
            Text(recommendation.brandName)
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
                .padding(.horizontal, 20)
            Text(recommendation.firstDescription)
                .font(.hanSansNeo(14, .medium))
                .padding(.top,8)
                .padding(.horizontal, 20)
            
            HStack(spacing: 4) {
                ForEach(recommendation.interests) { interest in
                    TagView(text: interest.name)
                }
            }
            .padding(.top,17)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
        }
        
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"))
        }
        .background(Color.white)
    
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
