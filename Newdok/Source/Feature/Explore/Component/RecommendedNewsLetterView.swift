//
//  NewsLetterView.swift
//  Newdok
//
//  Created by 권민재 on 3/2/25.
//

import SwiftUI

struct RecommendedNewsLetterView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image("signup")
                .resizable()
                .frame(height: 210)
            
            Text("뉴스레터 브랜드명")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
                .padding(.horizontal, 20)
            Text("소개글")
                .font(.hanSansNeo(14, .medium))
                .padding(.top,8)
                .padding(.horizontal, 20)
            
            HStack {
                TagView(text: "hello")
                TagView(text: "hello")
                TagView(text: "hello")
            }
            .padding(.top,17)
            .padding(.horizontal, 20)
            
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
