//
//  BrandDetailView.swift
//  Detail
//
//  Created by 권민재 on 5/7/25.
//

import SwiftUI
import Domain

public struct BrandDetailView: View {
    
    let detail: NewsletterDetail
    
    public init(detail: NewsletterDetail) {
        self.detail = detail
    }
    
    public var body: some View {
        ScrollView {
            
        }
    }
}

#Preview {
    BrandDetailView(
        detail: NewsletterDetail(
            id: 1,
            brandName: "뉴닉",
            firstDescription: "세상 돌아가는 소식은 궁금한데, 시간이 없다고요?",
            secondDescription: "<뉴닉>은 신문 볼 새 없이 바쁜 당신을 위한 뉴스레터예요.",
            publicationCycle: "매주 수요일",
            subscribeUrl: "https://newneek.co",
            imageUrl: "https://cdn.newneek.com/logo.png",
            createdAt: "2023-11-01T00:00:00Z",
            updatedAt: "2023-11-26T00:00:00Z",
            industries: [
                Industry(id: 1, name: "시사·상식"),
                Industry(id: 2, name: "비즈니스"),
                Industry(id: 3, name: "트렌드")
            ],
            interests: [
                Interest(id: 1, name: "정치"),
                Interest(id: 2, name: "경제")
            ]
        )
    )
}
