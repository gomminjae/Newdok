//
//  EditProfileView.swift
//  Mypage
//
//  Created by 권민재 on 5/8/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared
import Foundation
import Combine
import PopupView

public struct EditProfileView: View {
    
    @AppStorage("nickname") private var nickname: String = ""
    @State private var showEditInterest = false

    @EnvironmentObject private var router: AppRouter

    @FocusState private var isTextFieldFocused: Bool

    @EnvironmentObject private var viewModel: MypageViewModel

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("등록하신 정보에 맞춰\n뉴스레터를 추천해드려요")
                .font(.hanSansNeo(18, .bold))
                .padding(.top, 24)
                .padding(.bottom, 40)
                .allowsHitTesting(false)
            
            // MARK: 닉네임
            EditableRow(
                title: "닉네임",
                text: viewModel.user?.nickname ?? "",
                onEdit: {
                    router.push(.editNickname)
                }
            )
           
            // MARK: 종사산업
            let industryName = getIndustryName()
            EditableRow(
                title: "종사산업",
                text: industryName,
                placeholder: "산업군을 선택해주세요.",
                onEdit: {
                    router.push(.editIndustry)
                }
            )
            .padding(.top, 24)

            // MARK: 관심사
            if let interestSection = interestSectionView() {
                interestSection
                    .padding(.top, 24)
            } else {
                Button {
                    router.push(.editInterest)
                } label: {
                    EditableRow(
                        title: "관심사",
                        text: "",
                        placeholder: "관심사를 선택해주세요."
                    )
                }
                .padding(.top, 24)
            }

            Spacer()
        }
        .onAppear {
            // [CHANGED] 전역 ToastCenter만 사용. 지역 체크/NotificationCenter 제거
            Task { await viewModel.fetchuserInfo() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("RefreshProfile"))) { _ in
            Task { await viewModel.fetchuserInfo() }
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.pop() } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("프로필 편집")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTextFieldFocused = false }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
            }
        }
        .hideKeyboardOnTap()
        // [CHANGED] 로컬 .popup 토스트 제거. 전역 PopupView(루트) 하나만 사용
    }

    // MARK: - Helper
    private func getIndustryName() -> String {
        guard let id = viewModel.user?.industryId else { return "" }
        return SelectableItemStore.shared.name(for: id, in: .industry) ?? ""
    }

    private func interestSectionView() -> AnyView? {
        guard let interests = viewModel.user?.interests, !interests.isEmpty else { return nil }
        
        let interestNames = interests.compactMap {
            SelectableItemStore.shared.name(for: $0.id, in: .interest)
        }
        let items = interestNames + ["+"]
        let section = VStack(alignment: .leading, spacing: 8) {
            Text("관심사")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .allowsHitTesting(false)

            ChipFlowLayout(spacing: 8).callAsFunction {
                ForEach(interestNames, id: \.self) { item in
                    Text(item)
                        .font(.hanSansNeo(13, .regular))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#DADADA"), lineWidth: 1)
                        )
                        .allowsHitTesting(false)
                }

                Button {
                    router.push(.editInterest)
                } label: {
                    Image(asset: DesignSystemAsset.linePlus)
                        .renderingMode(.template)
                        .foregroundColor(.primaryNormal)
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.primaryNormal, lineWidth: 1)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        return AnyView(section)
    }
}

// MARK: - 재사용 가능한 편집 행
struct EditableRow: View {
    let title: String
    let text: String
    var placeholder: String = ""
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? Color(hex: "#969696") : Color(hex: "#565656"))
                    .font(.hanSansNeo(14, .medium))
                Spacer()
                Button(action: { onEdit?() }) {
                    Image(asset: DesignSystemAsset.lineEdit)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#363636"))
                }
            }
            .padding()
            .frame(height: 48)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "#DADADA"), lineWidth: 1)
            }
        }
    }
}

// MARK: - Chip Flow Layout
private struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 8

    struct Cache {
        var frames: [CGRect] = []
        var size: CGSize = .zero
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let horizontalPadding: CGFloat = 40 // EditProfileView uses 20pt horizontal padding on each side
        let fallbackWidth = UIScreen.main.bounds.width - horizontalPadding
        let maxWidth = proposal.width ?? fallbackWidth

        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for view in subviews {
            var size = view.sizeThatFits(.unspecified)
            size.width = min(size.width, maxWidth)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        let totalHeight = y + rowHeight
        let result = CGSize(width: maxWidth, height: totalHeight)
        cache.frames = frames
        cache.size = result
        return result
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        for (index, view) in subviews.enumerated() {
            guard index < cache.frames.count else { continue }
            let frame = cache.frames[index].offsetBy(dx: bounds.minX, dy: bounds.minY)
            view.place(
                at: CGPoint(x: frame.minX, y: frame.minY),
                proposal: ProposedViewSize(width: frame.width, height: frame.height)
            )
        }
    }
}
