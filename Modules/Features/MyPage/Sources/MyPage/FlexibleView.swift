//
//  FlexibleView.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI

public struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    public init(
        data: Data,
        spacing: CGFloat,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var rows: [[Data.Element]] = [[]]

        // 계산
        for element in data {
            let elementWidth = textWidth(of: content(element), maxHeight: 28)
            if width + elementWidth > geometry.size.width {
                rows.append([element])
                width = elementWidth + spacing
            } else {
                rows[rows.count - 1].append(element)
                width += elementWidth + spacing
            }
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
    }

    private func textWidth(of view: Content, maxHeight: CGFloat) -> CGFloat {
        // 임시 치환: 너비 추정값 (적절한 기본값 제공)
        return 80
    }
}
