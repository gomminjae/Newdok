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

    @State private var selectedIndustry: String? = nil
    @State private var selectedWeekday: String? = nil

    var onApply: (_ selectedIndustry: String, _ selectedWeekday: String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

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

            VStack(alignment: .leading, spacing: 12) {
                Text("산업 카테고리")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "565656"))
                    .padding(.horizontal, 24)

                FlowLayoutView(data: industries, spacing: 8) { industry in
                    SelectableChip(
                        text: industry,
                        isSelected: selectedIndustry == industry
                    ) {
                        selectedIndustry = industry
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 24)

            VStack(alignment: .leading, spacing: 12) {
                Text("발행요일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "3565656"))
                    .padding(.horizontal, 24)
                    .padding(.top,28)

                FlowLayoutView(data: weekdays, spacing: 8) { day in
                    SelectableChip(
                        text: day,
                        isSelected: selectedWeekday == day
                    ) {
                        selectedWeekday = day
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top,28)


            HStack(spacing: 12) {
                Button(action: {
                    selectedIndustry = nil
                    selectedWeekday = nil
                }) {
                    HStack {
                        Image(asset: DesignSystemAsset.lineReload)
                        Text("재설정")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color(hex: "565656"))
                    }
                    .frame(width: 78)
                    .frame(height: 40)
                }

                Button(action: {
                    if let industry = selectedIndustry,
                       let weekday = selectedWeekday {
                        onApply(industry, weekday)
                    }
                    dismiss()
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
            .padding(.bottom, 56)
            //.padding(.top,28)
            .padding(.horizontal, 24)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .cornerRadius(20)
        .presentationDetents([.fraction(0.7)])
        .presentationDragIndicator(.visible)
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
            let elementSize = CGSize(width: 80, height: 30)
            if width + elementSize.width + spacing > geometry.size.width {
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
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
