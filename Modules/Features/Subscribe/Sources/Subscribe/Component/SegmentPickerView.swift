//
//  SegmentPickerView.swift
//  Newdok
//
//  Created by 권민재 on 3/3/25.
//

import SwiftUI
import DesignSystem

public struct CustomSegmentedSlider: View {
    @Binding var selectedIndex: Int
    let titles: [String]

    public init(selectedIndex: Binding<Int>, titles: [String]) {
        self._selectedIndex = selectedIndex
        self.titles = titles
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: "#F5F5F7"))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
                )

            GeometryReader { geometry in
                let segmentWidth = geometry.size.width / CGFloat(titles.count)
                // 상하좌우 동일하게 2pt 여백을 주도록 너비/오프셋 계산
                let sliderWidth = segmentWidth - 4
                let sliderOffset = CGFloat(selectedIndex) * segmentWidth + 2

                ZStack(alignment: .leading) {
                    // 선택된 슬라이더 배경
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .frame(width: sliderWidth, height: 36)
                        .padding(.vertical, 2)
                        .shadow(color: .black.opacity(0.06), radius: 1, y: 1)
                        .offset(x: sliderOffset)
                        .animation(.easeInOut(duration: 0.25), value: selectedIndex)

                    // 각 버튼
                    HStack(spacing: 0) {
                        ForEach(titles.indices, id: \.self) { index in
                            Button(action: {
                                selectedIndex = index
                            }) {
                                Text(titles[index])
                                    .font(.hanSansNeo(14, .bold))
                                    .foregroundColor(selectedIndex == index ? .black : .gray)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding(.horizontal, 2)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 40)
    }
}
