//
//  EditInterestView.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import DesignSystem
import Shared

public struct EditInterestView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIds: Set<Int> = []

    private let interests = SelectableItemStore.shared.interests
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("관심사")
                        .font(.hanSansNeo(14, .bold))

                    Text("최소 3가지 이상을 선택해주세요.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(interests, id: \.id) { item in
                            Button(action: {
                                toggle(id: item.id)
                            }) {
                                Text(item.name)
                                    .font(.system(size: 14))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .background(selectedIds.contains(item.id) ? Color.white : Color(UIColor.systemGray6))
                                    .foregroundColor(selectedIds.contains(item.id) ? Color.primaryNormal : Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedIds.contains(item.id) ? Color.primaryNormal : Color.clear)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
            }

            // 하단 버튼
            Button(action: {
                // 저장 or dismiss
            }) {
                Text("변경하기")
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(selectedIds.count >= 3 ? Color.primaryNormal : Color(hex: "#F0F0F0"))
                    .foregroundColor(selectedIds.count >= 3 ? .white : Color(hex: "#B0B0B0"))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .disabled(selectedIds.count < 3)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("관심사 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }

    private func toggle(id: Int) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}
