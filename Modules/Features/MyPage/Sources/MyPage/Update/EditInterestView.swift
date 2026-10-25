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
    @Environment(MypageViewModel.self) private var viewModel
    private let onBack: () -> Void

    @State private var selectedIds: Set<Int> = []
    @State private var hasInitializedSelection = false

    private var interests: [SelectableItem] { viewModel.interests }
    private var unavailableIds: [Int] {
        selectedIds.subtracting(Set(interests.map(\.id))).sorted()
    }
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 헤더
            VStack(alignment: .leading, spacing: 8) {
                Text("관심사")
                    .font(.hanSansNeo(18, .bold))
                    .foregroundStyle(Color.captionDeep)
                    .allowsHitTesting(false)

                Text("최소 3가지 이상을 선택해주세요.")
                    .font(.hanSansNeo(14, .regular))
                    .foregroundColor(Color.captionBody)
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)

            if viewModel.optionsLoadState == .loaded && !interests.isEmpty {
                ScrollView {
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
                                    .foregroundColor(selectedIds.contains(item.id) ? Color.primaryNormal : Color.captionNeutral)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(selectedIds.contains(item.id) ? Color.primaryNormal : Color.lineNeutral)
                                    )
                                    .cornerRadius(4)
                            }
                        }
                        ForEach(unavailableIds, id: \.self) { id in
                            Button {
                                toggle(id: id)
                            } label: {
                                Text("이전 관심사 \(id) · 선택 해제")
                                    .font(.hanSansNeo(14, .medium))
                                    .frame(maxWidth: .infinity, minHeight: 48)
                                    .contentShape(Rectangle())
                            }
                            .accessibilityLabel("현재 목록에 없는 관심사 \(id) 선택 해제")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // 버튼 공간 확보
                }
            } else {
                SelectableOptionsStatusView(state: viewModel.optionsLoadState, onRetry: viewModel.loadOptions)
                Spacer()
            }

            Button(action: {
                Task { @MainActor in
                    let didUpdate = await viewModel.updateInterests(ids: Array(selectedIds))
                    guard didUpdate else { return }
                    await viewModel.fetchuserInfo()
                    onBack()
                    try await Task.sleep(nanoseconds: 150_000_000)
                    ToastCenter.shared.show("관심사가 변경되었습니다.")
                }
            }) {
                Group {
                    if viewModel.isInterestUpdating {
                        LoadingDotsView()
                    } else {
                        Text("변경하기")
                            .font(.hanSansNeo(14, .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    viewModel.isInterestUpdating
                        ? Color.primaryBgSubtle
                        : (viewModel.canUpdateInterests(ids: selectedIds) ? Color.primaryNormal : Color.bgTertiary)
                )
                .foregroundColor(viewModel.canUpdateInterests(ids: selectedIds) ? .white : Color.graySubtle)
                .cornerRadius(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .disabled(!viewModel.canUpdateInterests(ids: selectedIds))
        }
        .task { try? await viewModel.loadOptions() }
        .task {
            guard !hasInitializedSelection else { return }
            if viewModel.user == nil {
                await viewModel.fetchuserInfo()
            }
            guard !Task.isCancelled, !hasInitializedSelection else { return }
            selectedIds = Set(viewModel.user?.interests.map(\.id) ?? [])
            hasInitializedSelection = true
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { onBack() } label: {
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
        .onChange(of: viewModel.showInterestSuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "관심사가 변경되었습니다.")
                viewModel.showInterestSuccess = false
            }
        }
    }

    private func toggle(id: Int) {
        hasInitializedSelection = true
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}
