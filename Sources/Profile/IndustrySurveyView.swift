//
//  IndustrySurveyView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

public struct InterestSelectionView: View {
    let interests = [
           "경제·시사",
           "비즈니스",
           "과학·기술",
           "트렌드",
           "재테크",
           "콘텐츠",
           "라이프스타일",
           "취미·자기계발",
           "건강·의학",
           "멘탈케어",
           "푸드·드링크",
           "자연·환경",
           "리빙·인테리어",
           "미술·디자인",
           "음악",
           "게임·스포츠",
           "콘서트·공연",
           "문화",
           "문학·도서",
           "언어",
           "영화",
           "지역·여행",
           "가족",
           "쇼핑",
           "반려동물",
           "사회공헌"
       ]
    
    @State private var selectedInterests: Set<String> = []

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

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
                    ForEach(interests, id: \.self) { interest in
                        InterestButton(
                            title: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            toggleInterest(interest)
                        }
                    }
                }
                .padding(.top, 32)
            }
            .scrollIndicators(.hidden)

           
            Button(action: {
                print("선택된 관심사: \(selectedInterests.joined(separator: ", "))")
            }) {
                Text("뉴스레터 추천받기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selectedInterests.count >= 3 ? Color(hex: "#2866D3") : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .disabled(selectedInterests.count < 3)
            .padding(.top, 34)
        }
        .padding(.horizontal, 24)
    }
    private func toggleInterest(_ interest: String) {
        withAnimation {
            if selectedInterests.contains(interest) {
                selectedInterests.remove(interest)
            } else {
                selectedInterests.insert(interest)
            }
        }
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .blue : .black)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color(hex: "#2866D3") : Color.gray.opacity(0.3), lineWidth: 1)
                )
                
        }
    }
}

#Preview {
    InterestSelectionView()
}
