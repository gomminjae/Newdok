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
        case .check: return "구독확인 중"
        case .confirmed: return "구독중"
        case .paused: return "구독중지"
        default: return nil
        }
    }
    var color: Color {
        switch self {
        case .confirmed: return Color(hex: "#5184DB")
        case .paused: return .white
        default: return .clear
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .confirmed: return Color.white
        case .paused: return Color(hex: "#BDBDBD")
        default: return .clear
        }
    }
    
    var borderColor: Color {
        switch self {
        case .paused: return Color(hex: "#C0C0C0")
        case .confirmed: return Color(hex: "#2866D3")
        default: return .clear
        }
    }
}

struct NewsletterDetailRow: View {
    public var brand: Brand

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                KFImage(URL(string: brand.imageUrl))
                    .placeholder {
                        // 로딩 중 표시
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 56, height: 56)
                    }
                    .onFailure { error in
                    }
                    .onFailure { _ in
                        // 실패 시 기본 이미지 표시
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(Color.gray.opacity(0.5))
                            .frame(width: 56, height: 56)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(hex: "EBEBEB"), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 12) {
                    Text(brand.brandName)
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(Color(hex: "#161616"))
                        .padding(.leading, 8)
                        .padding(.top, 2)

                    Text(brand.shortDescription)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 8)
                }

                Spacer()

                if let label = SubscriptionStatus(rawValue: brand.isSubscribed ?? "").label {
                    Text(label)
                        .font(.hanSansNeo(11, .medium))
                        .foregroundColor(SubscriptionStatus(rawValue: brand.isSubscribed ?? "").foregroundColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(SubscriptionStatus(rawValue: brand.isSubscribed ?? "").color)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(SubscriptionStatus(rawValue: brand.isSubscribed ?? "").borderColor, lineWidth: 1)
                        }
                }
            }
            .padding(.bottom,18)
            
            HStack(spacing: 8) {
                ForEach(brand.interests.prefix(3)) { interest in
                    TagView(text: interest.name)
                }
            }
            .padding(.vertical, 4)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "EBEBEB"), lineWidth: 1)
        }
        
        
    }
}
