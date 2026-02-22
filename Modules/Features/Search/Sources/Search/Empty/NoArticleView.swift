//
//  NoArticleView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import DesignSystem
import Shared
struct NoArticleView: View {
    @EnvironmentObject private var router: AppRouter
    var body: some View {
        VStack {
            Text("검색 결과가 없어요.")
                .font(.hanSansNeo(16, .medium))
            Text("띄어쓰기를 포함하여 검색어가 정확한지 확인해주세요.")
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "555555"))
                .padding(.top, 4)
            Button(action: {
                router.push(.serviceFeedback)
            }) {
                Text("문의하기")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.primaryNormal)
                    .cornerRadius(8)
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    NoArticleView()
}
