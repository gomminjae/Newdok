//
//  FAQView.swift
//  Mypage
//
//  Created by 권민재 on 6/26/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

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
        구독 이메일은 회원가입 완료 시 자동으로 생성되는 뉴스레터 구독만을 위한 이메일 주소예요. 뉴독으로 아티클을 수신받기 위해서는 뉴독이 발급하는 구독 이메일이 꼭 필요해요.

        구독 이메일은 뉴독이 자체적으로 생성하여 제공하기 때문에 보통 이메일과 달리 개인적인 용도로의 사용이나 발신이 불가능하고, 오로지 [뉴스레터 수신]에만 사용할 수 있어요.
        """
    ),
    FAQItem(
        category: "뉴스레터",
        question: "뉴스레터가 뭔가요?",
        answer: """
            뉴스레터는 기업이나 개인이 특정한 산업이나 이슈에 대한 정보를 공유하는 것을 목적으로 구독자에게 정기적 혹은 비정기적으로 이메일을 보내는 것을 의미해요.

            다양한 주제로 수많은 뉴스레터가 발행되고 있는 만큼, 뉴스레터를 통해 내게 필요한 정보나 인사이트를 습득할 수 있고 최신 트렌드를 살펴볼 수도 있어요.

            어떤 뉴스레터를 구독해야할 지 모르겠다면 뉴독으로 내 취향과 필요에 맞는 뉴스레터를 추천받아보세요!
            """
    ),
    FAQItem(
        category: "뉴스레터",
        question: "아티클이 뭔가요?",
        answer: "아티클은 각 뉴스레터 브랜드가 정해진 날짜에 발행하는 수신물들을 의미해요. 뉴스레터가 수신하는 아티클들은 [홈] 화면에서 날짜별로 모아볼 수 있어요."
    ),
    FAQItem(
        category: "큐레이션",
        question: "관련이 없는 뉴스레터만 추천돼요. 어떻게 하나요?",
        answer: "추천 뉴스레터에 관련이 없는 뉴스레터만 뜬다면 프로필 정보가 잘못 설정되어 있을 수 있어요. 마이페이지 탭의[프로필 편집]에서 종사 산업과 관심사를 재설정할 수 있어요."
    ),
    FAQItem(
        category: "구독",
        question: "구독은 어떻게 신청하나요?",
        answer: """
            [구독하기] 버튼을 누르면 각 뉴스레터의 구독신청 페이지가 팝업으로 뜨고 구독 이메일 주소가 자동으로 복사돼요.

            복사된 이메일 주소를 입력란에 붙여넣고 닉네임을 입력하신 후, 구독하기 버튼을 누르면 구독이 완료됩니다!
            """
    ),
    FAQItem(
        category: "구독",
        question: "구독을 신청했는데 아티클이 수신되지 않아요",
        answer: """
            대부분의 뉴스레터는 발행일과 시간이 정해져있어요. 그렇기 때문에 구독을 신청한 뉴스레터의 이번 주 발행일시가 이미 지났다면, 첫 아티클은 다음 주의 발행일시에 맞춰 수신받을 수 있어요.

            뉴스레터를 빨리 받아보고 싶으시다면 둘러보기 탭의 [모든 뉴스레터]에서 필터 기능을 이용해 다음 요일에 수신되는 뉴스레터 리스트를 살펴보세요!
            """
    ),
    FAQItem(
        category: "구독",
        question: "구독을 신청했는데 아티클이 수신되지 않아요",
        answer: """
            대부분의 뉴스레터는 발행일과 시간이 정해져있어요. 그렇기 때문에 구독을 신청한 뉴스레터의 이번 주 발행일시가 이미 지났다면, 첫 아티클은 다음 주의 발행일시에 맞춰 수신받을 수 있어요.

            뉴스레터를 빨리 받아보고 싶으시다면 둘러보기 탭의 [모든 뉴스레터]에서 필터 기능을 이용해 다음 요일에 수신되는 뉴스레터 리스트를 살펴보세요!
            """
    ),
    FAQItem(
        category: "구독",
        question: "구독을 신청했는데 구독 확인이 필요하다고 해요. 구독 확인은 어떻게 하나요?",
        answer: """
            [구독 확인 중]으로 썸네일이 바뀐 뉴스레터는 구독 신청 이후 직접 구독 확인을 해야 하는 뉴스레터예요. 구독 확인 메일은 구독 신청 직후 발송되어 홈 화면에서 확인할 수 있어요.

            구독 확인 메일을 클릭하여 메일 본문의 [구독 확인] 버튼을 누르면 최종으로 구독 신청이 완료됩니다!
            """
    ),
    FAQItem(
        category: "구독",
        question: "구독이 완료되는 과정이 궁금해요",
        answer: """
            - 구독 확인이 필요한 경우
                
                [구독하기] 버튼을 눌러 구독을 신청하면 구독 상태가 [구독 확인 중]으로 변경되고, 구독 확인 메일이 발송돼요. 
                
                메일 본문에 삽입된 [구독 확인] 버튼을 눌러 구독 신청을 확인하고 첫 아티클을 수신받으면, 마이페이지 탭의 [구독 리스트]에서 구독이 완료된 것을 확인할 수 있습니다.
                
            - 구독 확인이 필요없는 경우
                
                [구독하기] 버튼을 눌러 구독을 신청하고 첫 아티클을 수신 받으면, 마이페이지 탭의 [구독 리스트]에서 구독이 완료된 것을 확인할 수 있습니다.
            """
    ),
    FAQItem(
        category: "구독관리",
        question: "구독 중인 뉴스레터를 확인하고 싶어요.",
        answer: """
            구독 중인 뉴스레터는 마이페이지 탭의 [구독 리스트]에서 확인할 수 있어요. 구독 신청 이후 해당 뉴스레터로부터 첫 아티클을 수신받으면 구독 리스트에 추가돼요.

            구독을 신청했는데 아직 구독 리스트에서 확인되지 않는다면 첫 아티클을 수신받을 때까지 조금만 기다려주세요!
            """
    ),
    FAQItem(
        category: "구독관리",
        question: "구독을 해지하고 싶어요.",
        answer: """
            구독 해지 기능은 아직 구현되지 않았어요. 열심히 개발 중에 있으니, 앞으로 추가될 기능에도 많은 기대 해주세요!
            """
    ),
    FAQItem(
        category: "일반",
        question: "1:1 문의를 하고 싶어요.",
        answer: """
            서비스 이용에 문의가 있으실 경우, 마이페이지 탭의 [서비스 피드백]을 통해 내용을 남겨주시거나 newdokcustomer@newdok.site 으로 메일을 보내주시면 빠른 시일 내에 도움을 드리겠습니다.
            """
    )
]

public struct FAQView: View {
    @State private var expandedFAQID: UUID?
    
    @EnvironmentObject private var router: AppRouter
    
    public init() {}

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sampleFAQs) { item in
                        FAQRow(
                            faq: item,
                            isExpanded: expandedFAQID == item.id
                        )
                        .id(item.id) // ScrollViewReader를 위한 ID
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if expandedFAQID == item.id {
                                    expandedFAQID = nil
                                } else {
                                    expandedFAQID = item.id
                                    // FAQ가 열릴 때 해당 항목으로 스크롤
                                    Task {
                                        try? await Task.sleep(for: .milliseconds(100))
                                        await MainActor.run {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                proxy.scrollTo(item.id, anchor: .top)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            // 📌 중앙 타이틀
            ToolbarItem(placement: .principal) {
                Text("FAQ")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
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
                    .foregroundColor(Color.captionHeavy)
                    .fixedSize(horizontal: false, vertical: true)
                 
                Spacer()

                Image(asset: DesignSystemAsset.lineDown)
                    .resizable()
                    .frame(width: 24, height: 24)
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
                        ? Color.primaryNormal
                        : Color.lineAlternative,
                    lineWidth: 1
                )
                .background(Color.white.cornerRadius(12))
        )
        .frame(maxWidth: .infinity)
    }
}
