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
    public let prioritizedInterests: [Interest]

    public init(newsletter: NewsletterDetail, prioritizedInterests: [Interest]? = nil) {
        self.newsletter = newsletter
        self.prioritizedInterests = prioritizedInterests ?? newsletter.interests
    }
    

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                KFImage(URL(string: newsletter.imageUrl ?? ""))
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 112, height: 112)))
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
                    Text(newsletter.brandName)
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(Color(hex: "#161616"))
                        .padding(.leading, 8)
                        .padding(.top, 2)

                    Text(newsletter.firstDescription)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 8)
                }

                Spacer()
            }
            .padding(.bottom, 18)
            
            // 관심사 태그 3개 표시 (우선순위 정렬된 관심사)
            if !prioritizedInterests.isEmpty {
                HStack(spacing: 8) {
                    ForEach(prioritizedInterests.prefix(3)) { interest in
                        TagView(text: interest.name)
                    }
                }
                .padding(.vertical, 4)
                .padding(.bottom, 16)
            }
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
