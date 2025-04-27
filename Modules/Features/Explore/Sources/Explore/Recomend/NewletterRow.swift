//
//  NewletterRow.swift
//  Explore
//
//  Created by 권민재 on 4/25/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Kingfisher
import DesignSystem
import Domain

public struct NewsletterRow: View {
    public let newsletter: NewsletterDetail

    public init(newsletter: NewsletterDetail) {
        self.newsletter = newsletter
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            KFImage(URL(string: newsletter.imageUrl))
                .placeholder {
                    Color.gray.opacity(0.2)
                }
                .resizable()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
                    )

            VStack(alignment: .leading, spacing: 4) {
                Text(newsletter.brandName)
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(Color(hex: "#333333"))

                Text(newsletter.firstDescription)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#363636"))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .overlay {
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(Color(hex: "EBEBEB"))
//        }
        .shadow(color: .clear, radius: 0) // 필요 시 그림자
    }
}
