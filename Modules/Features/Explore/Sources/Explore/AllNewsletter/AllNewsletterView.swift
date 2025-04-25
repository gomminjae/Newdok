//
//  AllNewsletterView.swift
//  Explore
//
//  Created by 권민재 on 4/25/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import Domain
import DesignSystem

//public struct AllNewsletterView: View {
//
//    public var body: some View {
//        VStack(spacing: 0) {
//            filterSection
//
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(newsletters, id: \.id) { brand in
//                        NewsletterDetailRow(brand: brand)
//                            .padding(.horizontal, 20)
//                    }
//                }
//                .padding(.top, 12)
//                .padding(.bottom, 80) // 탭바 간격 확보
//            }
//        }
//        .background(Color(hex: "#F5F5F7"))
//    }
//
//    // MARK: - 필터 영역
//    private var filterSection: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                filterTag("인기순 ⬇️")
//                filterTag("산업 ⌄")
//                filterTag("발행 요일 ⌄")
//                Button {
//                    print("새로고침")
//                } label: {
//                    Image(systemName: "arrow.clockwise")
//                        .foregroundColor(.blue)
//                        .frame(width: 32, height: 32)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 12)
//        }
//    }
//
//    private func filterTag(_ title: String) -> some View {
//        Text(title)
//            .font(.hanSansNeo(14, .medium))
//            .foregroundColor(Color(hex: "#363636"))
//            .padding(.horizontal, 14)
//            .padding(.vertical, 8)
//            .background(Color.white)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
//            )
//    }
//}
