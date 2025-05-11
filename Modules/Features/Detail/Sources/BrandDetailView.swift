//
//  BrandDetailView.swift
//  Detail
//
//  Created by 권민재 on 5/7/25.
//

import SwiftUI
import DesignSystem
import Kingfisher
import Domain
import Shared

public struct BrandDetailView: View {
    @StateObject private var viewModel: BrandDetailViewModel
    
    
    @EnvironmentObject private var router: AppRouter

    public init(viewModel: BrandDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            if viewModel.isLoading {
                //ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.detail {
                detailContent(detail)
            } else {
                Text("데이터를 불러올 수 없습니다.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(Color(hex: "F5F5F7"))
        .onAppear {
            Task { await viewModel.fetch() }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("뉴스레터 홈")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func detailContent(_ detail: BrandDetail) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: detail.imageUrl))
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)

                HStack(spacing: 4) {
                    ForEach(detail.interests.prefix(3), id: \..id) { interest in
                        Text(interest.name)
                            .font(.hanSansNeo(11, .medium))
                            .foregroundStyle(Color(hex: "363636"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "ffffff").opacity(0.61))
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color(hex: "EBEBEB"))
                            }
                    }
                }
                .padding(.top, 12)
                .padding(.leading, 16)

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
                        subscribeButton(isSubscribed: detail.subscribeCheck)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 21)
                    .background(Color(hex: "FFFFFF").opacity(0.6))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                    .padding(.horizontal)
                    .offset(y: 15)
                    .padding(.bottom, 12)

                }
            }
            .frame(height: 300)

            Text(detail.detailDescription)
                .font(.hanSansNeo(14, .regular))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: "555555"))
                .padding(.horizontal)
                .padding(.vertical, 12)
                
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
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "EBEBEB")))
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func subscribeButton(isSubscribed: Bool) -> some View {
        Button(action: {
            // TODO: 구독 토글
        }) {
            Text(isSubscribed ? "구독중지" : "구독하기")
                .frame(width: 95, height: 40)
                .font(.system(size: 14, weight: .semibold))
                .background(isSubscribed ? Color.white : Color.primaryNormal)
                .foregroundColor(isSubscribed ? Color(hex: "565656") : .white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSubscribed ? Color(hex: "EBEBEB") : .clear)
                )
        }
    }
}
