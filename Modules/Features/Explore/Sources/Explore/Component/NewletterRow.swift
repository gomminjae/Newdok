//
//  NewletterRow.swift
//  Explore
//
//  Created by 권민재 on 4/25/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI

struct NewsletterRow: View {
    let imageUrl: String
    let title: String
    let description: String
    let tags: [String]
    let isSubscribed: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .cornerRadius(12)
                case .failure(_):
                    Color.gray
                        .frame(width: 56, height: 56)
                        .cornerRadius(12)
                case .empty:
                    ProgressView()
                        .frame(width: 56, height: 56)
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))

                    Spacer()

                    Text(isSubscribed ? "구독중" : "구독하기")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSubscribed ? Color.blue : Color.gray)
                        .cornerRadius(16)
                }

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}

#Preview {
    NewsletterRow(
        imageUrl: "https://newdok.store/public/탐방레터.png",
        title: "NEWNEEK",
        description: "세상 돌아가는 소식, 뉴닉으로!",
        tags: ["시사·상식", "비즈니스", "트렌드"],
        isSubscribed: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
