//
//  SwiftUIView.swift
//  Explore
//
//  Created by 권민재 on 4/27/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct FilterBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    let industries = ["IT·게임·통신", "F&B", "패션", "유통·무역", "의료", "자영업", "생활·서비스", "건설", "광고", "교육", "금융·부동산", "미디어", "문화·예술·엔터", "생산·제조", "기타"]
    let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "기타"]

    @Binding var industry: [Int]?
    @Binding var day: [Int]?
    
    // 임시 필터 상태 (실제 필터에 반영되지 않음)
    @State private var tempIndustry: [Int]?
    @State private var tempDay: [Int]?
    
    var onApply: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 28)

            HStack {
                Text("필터")
                    .font(.hanSansNeo(20, .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 0) {
                Text("산업 카테고리")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "565656"))
                    .padding(.bottom, 8)
                FlowLayoutView(data: industries.indices, spacing: 8) { index in
                    SelectableChip(
                        text: industries[index],
                        isSelected: tempIndustry?.contains(index + 1) ?? false
                    ) {
                        toggleSelection(&tempIndustry, value: index + 1)
                    }
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 0) {
                Text("발행요일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "565656"))
                    
                FlowLayoutView(data: weekdays.indices, spacing: 8) { index in
                    SelectableChip(
                        text: weekdays[index],
                        isSelected: tempDay?.contains(index + 1) ?? false
                    ) {
                        toggleSelection(&tempDay, value: index + 1)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)

            

            HStack(spacing: 12) {
                Button(action: {
                    tempIndustry = nil
                    tempDay = nil
                }) {
                    HStack {
                        Image(asset: DesignSystemAsset.lineReload)
                        Text("재설정")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color(hex: "565656"))
                    }
                    .frame(width: 78, height: 40)
                }

                Button(action: {
                    // 적용하기 버튼을 눌렀을 때만 실제 필터에 반영
                    industry = tempIndustry
                    day = tempDay
                    Task {
                        await onApply()
                        dismiss()
                    }
                }) {
                    Text("적용하기")
                        .font(.hanSansNeo(14, .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.primaryNormal)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            // 시트가 나타날 때 현재 필터 상태를 임시 상태로 복사
            tempIndustry = industry
            tempDay = day
        }
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(580)])
        .presentationDragIndicator(.visible)
    }

    // ✅ 선택/해제 토글 함수
    private func toggleSelection(_ selection: inout [Int]?, value: Int) {
        if selection?.contains(value) == true {
            selection?.removeAll(where: { $0 == value })
            if selection?.isEmpty == true {
                selection = nil
            }
        } else {
            if selection == nil {
                selection = []
            }
            selection?.append(value)
        }
    }
}



struct SelectableChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(text)
            .font(.hanSansNeo(14, .medium))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .foregroundColor(isSelected ? .primaryNormal : Color(hex: "363636"))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .primaryNormal : Color(hex: "EBEBEB"))
            )
            .cornerRadius(16)
            .onTapGesture {
                action()
            }
    }
}

struct FlowLayoutView<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    init(data: Data,
         spacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var rows: [[Data.Element]] = [[]]

        for element in data {
            // 각 줄에 4개까지 들어가도록 계산
            let availableWidth = geometry.size.width - 48 // 좌우 패딩 제외
            let elementWidth = (availableWidth - (spacing * 3)) / 4 // 4개 칩 + 3개 간격
            let elementSize = CGSize(width: elementWidth, height: 30)
            
            if width + elementSize.width + spacing > availableWidth {
                width = 0
                rows.append([])
            }
            width += elementSize.width + spacing
            rows[rows.count - 1].append(element)
        }

        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { element in
                        content(element)
                    }
                    Spacer() // 남은 공간을 채움
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
