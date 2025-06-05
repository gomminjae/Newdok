//
//  FAQView.swift
//  DesignSystem
//
//  Created by 권민재 on 6/5/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

struct FAQItem: Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let answer: String
}

let sampleFAQs: [FAQItem] = [
    FAQItem(
        category: "뉴스레터",
        question: "구독 이메일이 뭔가요?",
        answer: """
        구독 이메일은 회원가입 시 생성하는 뉴스레터 구독만을 위한 이메일 주소로, 뉴독으로 아티클을 수신받기 위해서는 뉴독이 발급하는 구독 이메일이 꼭 필요합니다.

        구독 이메일은 뉴독이 자체적으로 생성하여 제공하기 때문에 보통 이메일과 달리 개인적인 용도로는 사용이 불가능하고, 오로지 「뉴스레터 수신」에만 사용할 수 있어요.
        """
    ),
    FAQItem(
        category: "뉴스레터",
        question: "뉴스레터가 뭔가요?",
        answer: "뉴스레터는 특정 주제에 대한 정기적·선별적 소식이나 콘텐츠를 이메일로 보내주는 구독 기반 서비스입니다."
    ),
    FAQItem(
        category: "뉴스레터",
        question: "아티클이 뭔가요?",
        answer: "아티클은 뉴독에서 발행하는 개별 콘텐츠 단위로, 주로 기술·트렌드·기획 등에 관한 글을 말합니다."
    ),
    FAQItem(
        category: "큐레이션",
        question: "관련이 없는 뉴스레터만 추천돼요. 어떻게 하나요?",
        answer: "큐레이션 알고리즘은 사용자의 클릭 이력과 구독 정보를 기반으로 작동합니다. 만약 전혀 관련 없는 콘텐츠만 추천된다면, 프로필 설정에서 관심사를 업데이트하거나, 피드백 버튼을 활용해 추천 품질을 높여주세요."
    ),
    FAQItem(
        category: "구독신청",
        question: "구독은 어떻게 신청하나요?",
        answer: "앱 내 구독 신청 페이지에서 원하는 뉴스레터를 검색한 후 ‘구독하기’ 버튼을 눌러주세요. 이메일 인증 절차가 끝나면 자동으로 구독이 시작됩니다."
    ),
]


struct FAQView: View {
    
    @State private var expandedFAQID: UUID? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleFAQs) { item in
                    FAQRow(
                        faq: item,
                        isExpanded: expandedFAQID == item.id
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if expandedFAQID == item.id {
                                expandedFAQID = nil
                            } else {
                                expandedFAQID = item.id
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct FAQRow: View {
    let faq: FAQItem
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            
            Text(faq.category)
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(.primaryNormal)
                .padding(.top, 19)

            HStack(alignment: .top, spacing: 8) {
                Text(faq.question)
                    .font(.hanSansNeo(16, .medium))
                    .foregroundColor(Color(hex: "#161616"))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Image(asset: DesignSystemAsset.lineDown)
                    .resizable()
                    .frame(width: 12, height: 6)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            .padding(.bottom, 18)

            if isExpanded {
                Text(faq.answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                    .transition(.opacity)
                    .padding(.bottom, 24)
            }
        }
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isExpanded
                        ? Color.primaryNormal   // 펼쳐진 상태일 때
                        : Color(hex: "#DADADA"), // 접힌 상태일 때
                    lineWidth: 1
                )
                .background(Color.white.cornerRadius(12))
        )
        .frame(maxWidth: .infinity)
    }
}


// 5. 미리보기
struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FAQView()
        }
    }
}
