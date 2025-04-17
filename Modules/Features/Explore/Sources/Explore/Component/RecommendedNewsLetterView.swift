//
//  NewsLetterView.swift
//  Newdok
//
//  Created by 권민재 on 3/2/25.
//

import SwiftUI
import DesignSystem

struct RecommendedNewsLetterView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image(asset: DesignSystemAsset.signup)
                .resizable()
                .frame(height: 210)
                .frame(width: 340)

            
            Text("뉴스레터 브랜드명")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
                .padding(.horizontal, 20)
            Text("소개글")
                .font(.hanSansNeo(14, .medium))
                .padding(.top,8)
                .padding(.horizontal, 20)
            
            HStack(spacing: 4) {
                TagView(text: "hello")
                TagView(text: "hello")
                TagView(text: "hello")
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

#Preview {
    RecommendedNewsLetterView()
}

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
