//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem
import Domain
import Kingfisher

struct CurationRow: View {
    let newsletter: NewsletterDetail
    let onSubscribe: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 12) {
                KFImage(URL(string: newsletter.imageUrl))
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(newsletter.brandName)
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(.black)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)

                        Text(newsletter.publicationCycle)
                            .font(.hanSansNeo(13))
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                Button(action: onSubscribe) {
                    Text("구독하기")
                        .font(.hanSansNeo(13, .bold))
                        .foregroundStyle(Color(hex: "#2866D3"))
                        .frame(width: 80, height: 32)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#2866D3"), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color(hex: "#F7F7F7"))

            // 🔹 하단 흰 배경 영역
            VStack(alignment: .leading, spacing: 12) {
                Text(newsletter.firstDescription)
                    .font(.hanSansNeo(14,.medium))
                    .foregroundStyle(Color(hex: "#363636"))

                HStack(spacing: 8) {
                    ForEach(newsletter.interests.prefix(3), id: \.id) { interest in
                        TagView(text: interest.name)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        )
    }
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

//#Preview {
//    CurationRow(
//        newsletter: NewsletterDetail(
//            id: 1,
//            brandName: "NEWNEEK",
//            firstDescription: "세상 돌아가는 소식, 뉴닉으로!",
//            publicationCycle: "매주 평일 아침",
//            subscribeUrl: "https://example.com",
//            imageUrl: "https://example.com/image.jpg",
//            interests: [
//                Interest(id: 1, name: "경제·시사"),
//                Interest(id: 2, name: "비즈니스"),
//                Interest(id: 3, name: "트렌드")
//            ]
//        )
//    ) {
//        print("구독하기 버튼 클릭")
//    }
//}
