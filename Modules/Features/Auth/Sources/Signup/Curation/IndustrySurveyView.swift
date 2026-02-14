//
//  IndustrySurveyView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import Domain

public struct InterestSelectionView: View {
    let interestMap: [String: String] = [
        "1": "경제·시사", "2": "비즈니스", "3": "과학·기술", "4": "트렌드", "5": "재테크",
        "6": "콘텐츠", "7": "라이프스타일", "8": "취미·자기계발", "9": "건강·의학", "10": "멘탈케어",
        "11": "푸드·드링크", "12": "자연·환경", "13": "리빙·인테리어", "14": "미술·디자인", "15": "음악",
        "16": "게임·스포츠", "17": "콘서트·공연", "18": "문화", "19": "문학·도서", "20": "언어",
        "21": "영화", "22": "지역·여행", "23": "가족", "24": "쇼핑", "25": "반려동물", "26": "사회공헌"
    ]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @ObservedObject private var viewModel: SignupViewModel

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("정확한 추천을 위해\n관심사를 3개 이상 선택해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)

            Text("취향에 맞는 뉴스레터를 추천해드려요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#565656"))
                .padding(.top, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(interestMap.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        InterestButton(
                            title: value,
                            isSelected: viewModel.selectedInterests.contains(key)
                        ) {
                            withAnimation {
                                viewModel.toggleInterest(key)
                            }
                        }
                        .animation(.easeInOut, value: viewModel.selectedInterests)
                    }
                }
                .padding(.top, 32)
            }
            .scrollIndicators(.hidden)

            Button(action: {
                viewModel.submitInterests()
            }) {
                Text("뉴스레터추천받기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(viewModel.selectedInterests.count >= 3 ? Color(hex: "#2866D3") : Color(hex: "EBEBEB"))
                    .foregroundColor(viewModel.selectedInterests.count >= 3 ? .white : Color(hex: "BDBDBD"))
                    .cornerRadius(4)
            }
            .disabled(viewModel.selectedInterests.count < 3)
            .padding(.top, 34)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(isSelected ? .primaryNormal : Color(hex: "#565656"))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color(hex: "#2866D3") : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
