//
//  IndustrySurveyView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct InterestSelectionView: View {
    let interests = [
        "시사 · 상식", "비즈니스", "과학 · 기술", "트렌드",
        "재테크", "콘텐츠", "라이프스타일", "비즈니스",
        "건강", "멘탈케어", "푸드 · 드링크", "자연 · 환경",
        "공간 · 인테리어", "미술 · 디자인"
    ]
    
    @State private var selectedInterests: Set<String> = []

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
        
            Text("정확한 추천을 위해\n관심사를 3개 이상 선택해주세요.")
                .font(.system(size: 18, weight: .bold))
            
            Text("취향에 맞는 뉴스레터를 추천해드려요.")
                .font(.system(size: 14))
                .foregroundColor(.gray)

    
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

           
            Button(action: {
                print("선택된 관심사: \(selectedInterests.joined(separator: ", "))")
            }) {
                Text("뉴스레터 추천받기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(selectedInterests.count >= 3 ? Color(hex: "#2866D3") : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
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
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color(hex: "#2866D3") : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(10)
        }
    }
}

#Preview {
    InterestSelectionView()
}
