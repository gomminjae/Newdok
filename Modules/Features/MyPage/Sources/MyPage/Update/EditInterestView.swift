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
    @ObservedObject private var viewModel: MypageViewModel

    @State private var selectedIds: Set<Int> = []

    private let interests = SelectableItemStore.shared.interests
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("관심사")
                        .font(.hanSansNeo(18, .bold))
                        .foregroundStyle(Color(hex: "1E1E1E"))

                    Text("최소 3가지 이상을 선택해주세요.")
                        .font(.hanSansNeo(14, .regular))
                        .foregroundColor(Color(hex: "555555"))

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(interests, id: \.id) { item in
                            Button(action: {
                                toggle(id: item.id)
                            }) {
                                Text(item.name)
                                    .font(.hanSansNeo(14, .medium))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color.white)
                                    .foregroundColor(selectedIds.contains(item.id) ? Color.primaryNormal : Color(hex: "565656"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(selectedIds.contains(item.id) ? Color.primaryNormal : Color(hex: "EBEBEB"))
                                    )
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
            }

            // ✅ 저장 버튼 - API 호출만 추가
            Button(action: {
                Task {
                    await viewModel.updateInterests(ids: Array(selectedIds))
                    viewModel.showInterestToast = true
                    dismiss()
                }
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
        .onAppear {
            // ✅ viewModel.user 기준으로 selectedIds 세팅
            if let interests = viewModel.user?.interests {
                selectedIds = Set(interests.map { $0.id })
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
