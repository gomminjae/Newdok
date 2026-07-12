//
//  EditAlertView.swift
//  Mypage
//
//  Created by 권민재 on 8/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Shared
import DesignSystem

public struct EditAlertView: View {
    @State private var isArticleAlert: Bool = false
    @State private var isUpdateAlert: Bool = false
    @State private var isRecommendAlert: Bool = false

    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("아티클")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.bottom, 24)

                Toggle(isOn: $isArticleAlert) {
                    Text("새로운 아티클")
                        .font(.hanSansNeo(16, .medium))
                        .foregroundStyle(Color.captionHeavy)
                }
                .tint(Color.primaryNormal)

                Text("구독 중인 뉴스레터의 새로운 아티클이 수신되었을 때\n알려드려요.")
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.bottom, 48)

                Text("새소식")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.bottom, 24)

                Toggle(isOn: $isUpdateAlert) {
                    Text("업데이트")
                        .font(.hanSansNeo(16, .medium))
                        .foregroundStyle(Color.captionHeavy)
                }
                .tint(Color.primaryNormal)

                Text("새로운 뉴스레터 브랜드가 등록 되었거나, 뉴독의\n업데이트 소식이 있을 때 알려드려요")
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.bottom, 20)

                Toggle(isOn: $isRecommendAlert) {
                    Text("뉴스레터 추천")
                        .font(.hanSansNeo(16, .medium))
                        .foregroundStyle(Color.captionHeavy)
                }
                .tint(Color.primaryNormal)

                Text("놓치면 후회할 인기 뉴스레터나, 최근 떠오르는\n뉴스레터를 알려드려요")
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .padding(.bottom, 20)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 8) {
                        Image(asset: DesignSystemAsset.lineQuestionMark)
                            .renderingMode(.template)
                            .foregroundStyle(Color.captionAssistive)
                        Text("알림 수신에 동의하셨음에도 알림이 오지 않는 경우,\n기기 자체 설정을 확인해 주세요.")
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color.captionNeutral)
                    }

                    Text("*확인 경로 : [휴대폰 설정 > 알림 > 뉴독]")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color.primaryNormal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    Color.bgSystem,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .padding(.bottom, 208)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 24)
        }
       
        .contentMargins(.top, 24)

        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.white, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { onBack() } label: {
                    Image(asset: DesignSystemAsset.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("알림 설정")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
