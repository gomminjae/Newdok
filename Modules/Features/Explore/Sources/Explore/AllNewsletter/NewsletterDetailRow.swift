//
//  NewsletterDetailRow.swift
//  Explore
//
//  Created by 권민재 on 4/25/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Kingfisher
import Domain
import DesignSystem

enum SubscriptionStatus: String {
    case initial = "INITIAL"
    case check = "CHECK"
    case confirmed = "CONFIRMED"
    case paused = "PAUSED"
    case unknown

    init(rawValue: String) {
        switch rawValue.uppercased() {
        case "INITIAL": self = .initial
        case "CHECK": self = .check
        case "CONFIRMED": self = .confirmed
        case "PAUSED": self = .paused
        default: self = .unknown
        }
    }

    var label: String? {
        switch self {
        case .confirmed: return "구독중"
        case .check: return "확인 중"
        case .paused: return "구독중지"
        default: return nil
        }
    }
    var color: Color {
        switch self {
        case .initial: return Color(hex: "#FFA500")
        default: return Color(hex: "5184DB")
        }
    }
}

struct NewsletterDetailRow: View {
    public var brand: Brand

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                KFImage(URL(string: brand.imageUrl))
                    .placeholder { Color.gray.opacity(0.2) }
                    .resizable()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 6) {
                    Text(brand.brandName)
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(Color(hex: "#161616"))

                    Text(brand.shortDescription)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if let label = SubscriptionStatus(rawValue: brand.isSubscribed).label {
                    Text(label)
                        .font(.hanSansNeo(13, .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SubscriptionStatus(rawValue: brand.isSubscribed).color)
                        .clipShape(Capsule())
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(brand.interests) { interest in
                        TagView(text: interest.name)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}
