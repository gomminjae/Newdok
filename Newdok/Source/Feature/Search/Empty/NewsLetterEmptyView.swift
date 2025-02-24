//
//  NewsLetterEmptyView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

struct NewsLetterEmptyView: View {
    var body: some View {
        VStack {
            Text("검색 결과가 없어요.")
                .font(.hanSansNeo(16, .medium))
            Text("찾는 뉴스레터가 없다면 등록을 요청해보세요.")
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "555555"))
                .padding(.top,4)
            Button("뉴스레터 등록 요청하기") {
                print("regi")
            }
            .font(.hanSansNeo(16, .bold))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primaryNormal, lineWidth: 1)
            )
            .foregroundStyle(Color.primaryNormal)
            .padding(.top,24)
            .padding(.horizontal, 24)
        }
        .background(.clear)
    }
}

#Preview {
    NewsLetterEmptyView()
}
