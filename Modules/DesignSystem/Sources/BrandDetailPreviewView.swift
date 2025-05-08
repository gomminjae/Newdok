//
//  BrandDetailPreviewView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/8/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//


import SwiftUI


public struct BrandDetail {
    public let brandId: Int
    public let brandName: String
    public let detailDescription: String
    public let publicationCycle: String
    public let subscribeUrl: String
    public let imageUrl: String
    public let interests: [Interest]
    public let brandArticleList: [BrandArticle]
    public let isSubscribed: String
    public let subscribeCheck: Bool
}

public struct BrandArticle: Identifiable {
    public let id: Int
    public let title: String
    public let date: String
}

public struct Industry: Identifiable, Equatable {
    public let id: Int
    public let name: String
}

public struct Interest: Identifiable, Equatable {
    public let id: Int
    public let name: String
}

import SwiftUI

public struct BrandDetailPreviewView: View {
    let detail = BrandDetail.previewDummy

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - 상단 전체 영역 (태그 + 배너 + 구독 카드)
                ZStack(alignment: .topLeading) {
                    // 배너 이미지
                    Image(asset: DesignSystemAsset.banner)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)

                    // 태그 (이미지 위에 떠 있음)
                    HStack(spacing: 8) {
                        ForEach(detail.interests, id: \.id) { interest in
                            Text(interest.name)
                                .font(.caption)
                                .foregroundStyle(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "ffffff").opacity(0.61))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.leading, 16)

                    // 오버레이 카드 (이미지 아래쪽에 붙어 있는 형태)
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(detail.brandName)
                                    .font(.hanSansNeo(16, .bold))

                                HStack(spacing: 4) {
                                    Image(asset: DesignSystemAsset.lineClock)
                                        .renderingMode(.template)
                                        .resizable()
                                        .foregroundStyle(Color(hex: "565656"))
                                        .frame(width: 20, height: 20)

                                    Text(detail.publicationCycle)
                                        .font(.hanSansNeo(12, .medium))
                                        .foregroundStyle(Color(hex: "565656"))
                                }
                            }

                            Spacer()

                            Button(action: {}) {
                                Text(detail.subscribeCheck ? "구독중지" : "구독하기")
                                    .frame(width: 95, height: 40)
                                    .font(.system(size: 14, weight: .semibold))
                                    .background(detail.subscribeCheck ? Color(hex: "FFFFFF") : Color.primaryNormal)
                                    .foregroundColor(detail.subscribeCheck ? Color(hex: "565656") : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(detail.subscribeCheck ? Color(hex: "EBEBEB") : Color.clear)
                                    }
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 21)
                        .background(Color(hex: "ffffff").opacity(0.8))
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                        .padding(.horizontal)
                        .offset(y: 15)
                    }
                }
                .frame(height: 300)
                

                // MARK: - 설명
                Text(detail.detailDescription)
                    .font(.hanSansNeo(14, .regular))
                    .lineSpacing(4)
                    .foregroundStyle(Color(hex: "555555"))
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .padding(.top, 12)

                // MARK: - 아티클 목록
                VStack(alignment: .leading, spacing: 8) {
                    Text("지난 아티클 보기")
                        .font(.hanSansNeo(14, .bold))
                        .padding(.leading, 28)
                        .padding(.top, 20)

                    ForEach(detail.brandArticleList) { article in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(article.title)
                                .font(.hanSansNeo(14, .bold))
                                .foregroundStyle(Color(hex: "363636"))
                                .padding(.bottom, 4)

                            HStack {
                                Text(article.date)
                                    .font(.hanSansNeo(12, .medium))
                                    .foregroundColor(Color(hex: "565656"))

                                Divider()

                                Text("오전 7:06")
                                    .font(.hanSansNeo(12, .medium))
                                    .foregroundColor(Color(hex: "565656"))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "EBEBEB"))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color(hex: "F5F5F7"))
    }
}




public extension BrandDetail {
    static let previewDummy = BrandDetail(
        brandId: 1,
        brandName: "뉴닉",
        detailDescription: "세상 돌아가는 소식은 궁금한데, 시간이 없다고요? <뉴닉>은 신문 볼 새 없이 바쁘지만, 세상과의 연결고리는 튼튼하게 유지하고 싶은 여러분들을 위해 세상 돌아가는 소식을 모두 담아 간단하게 정리해드려요.",
        publicationCycle: "매주 수요일",
        subscribeUrl: "https://newneek.co",
        imageUrl: "https://cdn.newneek.com/banner.jpg",
        interests: [
            Interest(id: 1, name: "정치"),
            Interest(id: 2, name: "경제")
        ],
        brandArticleList: [
            BrandArticle(id: 1, title: "🦔 정원 늘어난다 쭉쭉쭉쭉~?", date: "2023-11-26"),
            BrandArticle(id: 2, title: "(광고)🦔 우리 사이 멀어질까 두려워", date: "2023-11-24"),
            BrandArticle(id: 3, title: "🦔 또 내 지갑만 진심(으로 텅텅)이지", date: "2023-11-22")
        ],
        isSubscribed: "Y",
        subscribeCheck: true
    )
}

#Preview {
    BrandDetailPreviewView()
}
