//
//  SwiftUIView.swift
//  Explore
//
//  Created by 권민재 on 4/27/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared
import UIKit

// MARK: - Layout constants (rename: Layout -> L)
private enum L {
    static let horizontal: CGFloat = 24
    static let titleToChips: CGFloat = 8
    static let sectionGap: CGFloat = 22
    static let chipRowSpacing: CGFloat = 10
    static let weekdaysToButtons: CGFloat = 28
    static let top: CGFloat = 16
    static let bottom: CGFloat = 16
}

private struct HeightKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
private extension View {
    func reportHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(key: HeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(HeightKey.self, perform: onChange)
    }
}

struct FilterBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    let industries = SelectableItemStore.shared.industries
    let weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일", "기타"]

    @Binding var industry: [Int]?
    @Binding var day: [Int]?

    @State private var tempIndustry: [Int]?
    @State private var tempDay: [Int]?

    @State private var sheetHeight: CGFloat = 360

    var onApply: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 그랩바
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)
           
            HStack {
                Text("필터")
                    .font(.hanSansNeo(20, .bold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, L.horizontal)

            // 산업 카테고리
            VStack(alignment: .leading, spacing: 0) {
                Text("산업 카테고리")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                    .padding(.bottom, L.titleToChips)

                // ⬇️ Layout 컨테이너는 callAsFunction로 호출해야 View가 됩니다.
                FlowRowsLayout(spacing: L.chipRowSpacing).callAsFunction {
                    ForEach(industries, id: \.id) { item in
                        SelectableChip(
                            text: item.name,
                            isSelected: tempIndustry?.contains(item.id) ?? false
                        ) { toggleSelection(&tempIndustry, value: item.id) }
                        .frame(height: 36)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, L.top)
            .padding(.horizontal, L.horizontal)
            .padding(.bottom, L.sectionGap)

            // 발행요일
            VStack(alignment: .leading, spacing: 0) {
                Text("발행요일")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                    .padding(.bottom, L.titleToChips)

                FlowRowsLayout(spacing: L.chipRowSpacing).callAsFunction {
                    ForEach(Array(weekdays.enumerated()), id: \.offset) { idx, name in
                        let id = idx + 1
                        SelectableChip(
                            text: name,
                            isSelected: tempDay?.contains(id) ?? false
                        ) { toggleSelection(&tempDay, value: id) }
                        .frame(height: 36)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, L.horizontal)
            .padding(.bottom, L.weekdaysToButtons)

            // 버튼 영역
            HStack(spacing: 12) {
                Button(action: {
                    tempIndustry = nil
                    tempDay = nil
                }) {
                    HStack(spacing: 6) {
                        Image(asset: DesignSystemAsset.lineReload)
                        Text("재설정")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.captionNeutral)
                    }
                    .frame(width: 88, height: 40)
                }

                Button(action: {
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
            .padding(.horizontal, L.horizontal)
            .padding(.bottom, L.bottom)
        }
        // 콘텐츠 높이 측정 (⬇️ safeArea.bottom 중복 가산 제거)
        .reportHeight { h in
            let screenH = UIScreen.main.bounds.height
            let minH: CGFloat = 280
            let maxH: CGFloat = min(screenH * 0.9, 900)

            // 시스템이 시트 하단을 이미 보정하므로 safeBottom 더하지 않음
            var clamped = h + 1
            clamped = min(max(clamped, minH), maxH)

            if abs(clamped - sheetHeight) > 0.5 {
                sheetHeight = (clamped * 2).rounded() / 2
            }
        }
        .onAppear {
            tempIndustry = industry
            tempDay = day
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(sheetHeight)])
        .presentationDragIndicator(.hidden)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 6) // 필요시 0~10 사이 조정
        }
    }

    private func toggleSelection(_ selection: inout [Int]?, value: Int) {
        if selection?.contains(value) == true {
            selection?.removeAll(where: { $0 == value })
            if selection?.isEmpty == true { selection = nil }
        } else {
            if selection == nil { selection = [] }
            selection?.append(value)
        }
    }
}

// MARK: - Chip
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
            .foregroundColor(isSelected ? .primaryNormal : Color.captionStrong)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? .primaryNormal : Color.lineNeutral, lineWidth: 1)
            )
            .cornerRadius(16)
            .contentShape(Rectangle())
            .onTapGesture { action() }
    }
}

// MARK: - Flow layout (iOS 16/17 호환, GeometryReader 미사용)
struct FlowRowsLayout: Layout {
    var spacing: CGFloat = 12

    struct Cache { var frames: [CGRect] = []; var size: CGSize = .zero }

    func makeCache(subviews: SwiftUI.LayoutSubviews) -> Cache { Cache() }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: SwiftUI.LayoutSubviews,
        cache: inout Cache
    ) -> CGSize {
        // 제안된 너비가 없으면 안전한 기본값(좌우 패딩 고려)
        let fallbackW = UIScreen.main.bounds.width - L.horizontal * 2
        let maxW = proposal.width ?? fallbackW

        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        var frames: [CGRect] = []

        for v in subviews {
            var sz = v.sizeThatFits(.unspecified)
            sz.width = min(sz.width, maxW)
            if x > 0, x + sz.width > maxW { // 줄바꿈
                x = 0; y += rowH + spacing; rowH = 0
            }
            frames.append(CGRect(x: x, y: y, width: sz.width, height: sz.height))
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
        }

        let totalH = y + rowH
        cache.frames = frames
        cache.size = CGSize(width: maxW, height: totalH)
        return cache.size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: SwiftUI.LayoutSubviews,
        cache: inout Cache
    ) {
        for (i, v) in subviews.enumerated() {
            let f = cache.frames[i].offsetBy(dx: bounds.minX, dy: bounds.minY)
            v.place(
                at: CGPoint(x: f.minX, y: f.minY),
                proposal: ProposedViewSize(width: f.width, height: f.height)
            )
        }
    }
}
