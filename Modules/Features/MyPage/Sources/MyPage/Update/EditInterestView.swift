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
    @EnvironmentObject private var viewModel: MypageViewModel
    @EnvironmentObject private var router: AppRouter

    @State private var selectedIds: Set<Int> = []

    private let interests = SelectableItemStore.shared.interests
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // 헤더
            VStack(alignment: .leading, spacing: 8) {
                Text("관심사")
                    .font(.hanSansNeo(18, .bold))
                    .foregroundStyle(Color(hex: "1E1E1E"))
                    .allowsHitTesting(false)

                Text("최소 3가지 이상을 선택해주세요.")
                    .font(.hanSansNeo(14, .regular))
                    .foregroundColor(Color(hex: "555555"))
                    .allowsHitTesting(false)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)

            
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
                                .foregroundColor(selectedIds.contains(item.id) ? Color.primaryNormal : Color(hex: "565656"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(selectedIds.contains(item.id) ? Color.primaryNormal : Color(hex: "EBEBEB"))
                                )
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // 버튼 공간 확보
            }

          
            Button(action: {
                Task {
                    do {
                        try await viewModel.updateInterests(ids: Array(selectedIds))
                        await viewModel.fetchuserInfo()
                        
                        // showInterestSuccess 플래그 설정으로 EditProfileView에서 토스트 표시 및 업데이트 트리거
                        viewModel.showInterestSuccess = true
                        
                        await MainActor.run {
                            router.pop()
                        }
                    } catch {
                        print("❌ [EditInterestView] 관심사 변경 실패: \(error)")
                    }
                }
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(selectedIds.count >= 3 ? Color.primaryNormal : Color(hex: "#F0F0F0"))
                    .foregroundColor(selectedIds.count >= 3 ? .white : Color(hex: "#B0B0B0"))
                    .cornerRadius(4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
            .disabled(selectedIds.count < 3)
        }
        .onAppear {
            Task {
               
                await viewModel.fetchuserInfo()
                if let userInterests = viewModel.user?.interests {
                    selectedIds = Set(userInterests.map { $0.id })
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
                Text("관심사 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .onAppear {
            
            if let interests = viewModel.user?.interests {
                selectedIds = Set(interests.map { $0.id })
            }
        }
        .onChange(of: viewModel.showInterestSuccess) { showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "관심사가 변경되었습니다.")
                viewModel.showInterestSuccess = false
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
