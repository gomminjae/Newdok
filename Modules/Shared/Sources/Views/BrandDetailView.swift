//
//  BrandDetailView.swift
//  Shared
//
//  Created by 권민재 on 5/7/25.
//

//import SwiftUI
//import DesignSystem
//import Kingfisher
//
//public struct BrandDetailView: View {
//    let detail: BrandDetail?
//
//
//    public var body: some View {
//        let isSubscribed = detail?.subscribeCheck ?? false
//
//        ScrollView {
//            VStack(spacing: 0) {
//                // MARK: - 상단 전체 영역 (태그 + 배너 + 구독 카드)
//                ZStack(alignment: .topLeading) {
//                    // 배너 이미지
//                    Image(asset: DesignSystemAsset.banner)
//                        .resizable()
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 260)
//
//                    // 태그
//                    HStack(spacing: 8) {
//                        ForEach(detail?.interests ?? [], id: \.id) { interest in
//                            Text(interest.name)
//                                .font(.caption)
//                                .foregroundStyle(.black)
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 6)
//                                .background(Color(hex: "ffffff").opacity(0.61))
//                                .cornerRadius(20)
//                        }
//                    }
//                    .padding(.top, 12)
//                    .padding(.leading, 16)
//
//                    // 오버레이 카드
//                    VStack {
//                        Spacer()
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(detail?.brandName ?? "")
//                                    .font(.hanSansNeo(16, .bold))
//
//                                HStack(spacing: 4) {
//                                    Image(asset: DesignSystemAsset.lineClock)
//                                        .renderingMode(.template)
//                                        .resizable()
//                                        .foregroundStyle(Color(hex: "565656"))
//                                        .frame(width: 20, height: 20)
//
//                                    Text(detail?.publicationCycle ?? "")
//                                        .font(.hanSansNeo(12, .medium))
//                                        .foregroundStyle(Color(hex: "565656"))
//                                }
//                            }
//
//                            Spacer()
//
//                            subscribeButton(isSubscribed: isSubscribed)
//                        }
//                        .padding(.top, 20)
//                        .padding(.horizontal, 24)
//                        .padding(.bottom, 21)
//                        .background(Color(hex: "ffffff").opacity(0.8))
//                        .cornerRadius(8)
//                        .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
//                        .padding(.horizontal)
//                        .offset(y: 15)
//                    }
//                }
//                .frame(height: 300)
//
//                // MARK: - 설명
//                Text(detail?.detailDescription ?? "")
//                    .font(.hanSansNeo(14, .regular))
//                    .lineSpacing(4)
//                    .foregroundStyle(Color(hex: "555555"))
//                    .padding(.horizontal)
//                    .padding(.bottom, 12)
//                    .padding(.top, 12)
//
//                // MARK: - 아티클 목록
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("지난 아티클 보기")
//                        .font(.hanSansNeo(14, .bold))
//                        .padding(.leading, 28)
//                        .padding(.top, 20)
//
//                    ForEach(detail?.brandArticleList ?? []) { article in
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(article.title)
//                                .font(.hanSansNeo(14, .bold))
//                                .foregroundStyle(Color(hex: "363636"))
//                                .padding(.bottom, 4)
//
//                            HStack {
//                                Text(article.date)
//                                    .font(.hanSansNeo(12, .medium))
//                                    .foregroundColor(Color(hex: "565656"))
//
//                                Divider()
//
//                                Text("오전 7:06")
//                                    .font(.hanSansNeo(12, .medium))
//                                    .foregroundColor(Color(hex: "565656"))
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 16)
//                        .background(Color.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color(hex: "EBEBEB"))
//                        }
//                        .padding(.horizontal)
//                    }
//                }
//                .padding(.bottom, 32)
//            }
//        }
//        .background(Color(hex: "F5F5F7"))
//    }
//
//    @ViewBuilder
//    private func subscribeButton(isSubscribed: Bool) -> some View {
//        Button(action: {
//            // TODO: 구독 토글 액션
//        }) {
//            Text(isSubscribed ? "구독중지" : "구독하기")
//                .frame(width: 95, height: 40)
//                .font(.system(size: 14, weight: .semibold))
//                .background(isSubscribed ? Color(hex: "FFFFFF") : Color.primaryNormal)
//                .foregroundColor(isSubscribed ? Color(hex: "565656") : Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 4))
//                .overlay {
//                    RoundedRectangle(cornerRadius: 4)
//                        .stroke(isSubscribed ? Color(hex: "EBEBEB") : Color.clear)
//                }
//        }
//    }
//}
