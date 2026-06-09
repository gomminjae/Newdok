//
//  HighlightListView.swift
//  Detail
//
//  Created by 권민재 on 2/24/26.
//

import SwiftUI
import DesignSystem
import DetailDomain
import FoundationKit

// MARK: - Highlight List View
struct HighlightListView: View {
    @Environment(\.dismiss)
    private var dismiss

    let highlights: [DetailHighlight]
    let onSelectHighlight: (DetailHighlight) -> Void
    var onDeleteHighlight: ((DetailHighlight) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Text("하이라이트")
                    .font(.hanSansNeo(18, .bold))
                    .foregroundColor(.black)
                    .tracking(-18 * 0.03)
                    .lineSpacing(26 - 18)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(asset: DesignSystemAsset.lineClose)
                        .renderingMode(.template)
                        .foregroundColor(Color.captionNeutral)
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 24)
            .padding(.top, 53)
            .padding(.bottom, 16)

            if highlights.isEmpty {
                VStack(spacing: 16) {
                    Image(asset: DesignSystemAsset.nohighlight)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 260, height: 260)

                    Text("하이라이트한 문장이 없어요")
                        .font(.hanSansNeo(16, .bold))
                        .foregroundColor(.black)
                        .tracking(-16 * 0.03)
                        .lineSpacing(24 - 16)

                    Text("기억하고 싶은 문장을 길게 눌러\n형광펜이나 밑줄로 표시해 보세요")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(.gray)
                        .tracking(-14 * 0.03)
                        .lineSpacing(20 - 14)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 84)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(highlights, id: \.id) { highlight in
                            HighlightRowView(
                                highlight: highlight,
                                onDelete: {
                                    onDeleteHighlight?(highlight)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectHighlight(highlight)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

// MARK: - Highlight Row View
struct HighlightRowView: View {
    let highlight: DetailHighlight
    let onDelete: () -> Void

    private var highlightColor: Color {
        switch highlight.style {
        case .yellow: return Color.highlightYellow
        case .orange: return Color.highlightOrange
        case .pink: return Color.highlightPink
        case .green: return Color.highlightGreen
        case .blue: return Color.highlightBlue
        case .underline: return Color.errorLight
        }
    }

    private var barWidth: CGFloat {
        highlight.style == .underline ? 2 : 6
    }

    private var barRadius: CGFloat {
        highlight.style == .underline ? 1 : 3
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 좌측 컬러바
            RoundedRectangle(cornerRadius: barRadius)
                .fill(highlightColor)
                .frame(width: barWidth)

            // 콘텐츠
            VStack(alignment: .leading, spacing: 4) {
                Text("\u{201C}")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)

                Text(highlight.selectedText)
                    .font(.hanSansNeo(14, .regular))
                    .foregroundColor(.black)
                    .lineLimit(2)

                HStack(alignment: .bottom) {
                    Text(formatDate(highlight.createdAt))
                        .font(.hanSansNeo(12, .regular))
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: onDelete) {
                        Image(asset: DesignSystemAsset.lineTrash)
                            .renderingMode(.template)
                            .foregroundColor(.gray)
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.vertical, 12)
        }
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func formatDate(_ date: Date) -> String {
        date.newdokHighlightDateTimeText
    }
}
