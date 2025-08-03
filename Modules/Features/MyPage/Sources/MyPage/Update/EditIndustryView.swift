//
//  EditIndustryView.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

extension String {
    func ifEmpty(_ replacement: String) -> String {
        return self.isEmpty ? replacement : self
    }
}

public struct EditIndustryView: View {
    @State private var selectedId: Int?
    @State private var isExpanded: Bool = false

    @ObservedObject private var viewModel: MypageViewModel
    @EnvironmentObject private var router: AppRouter

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종사 산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
                .allowsHitTesting(false) // 터치 불가능하게 설정

            Button(action: {
                withAnimation { isExpanded.toggle() }
            }) {
                HStack {
                    Text(
                        SelectableItemStore.shared.name(for: selectedId ?? -1, in: .industry)
                            .ifEmpty("선택해주세요")
                    )
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "363636"))

                    Spacer()
                    Image(asset: isExpanded ? DesignSystemAsset.lineUp : DesignSystemAsset.lineDown)
                        .foregroundColor(Color(hex: "#363636"))
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(.white)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isExpanded ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
                )
            }

            if isExpanded {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(SelectableItemStore.shared.industries, id: \.id) { item in
                            Button {
                                selectedId = item.id
                                isExpanded = false
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundColor(item.id == selectedId ? Color.primaryNormal : Color(hex: "363636"))
                                        .font(.hanSansNeo(14, .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    item.id == selectedId
                                        ? Color(hex: "#E9EFFA")
                                        : Color.white
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
                .background(Color.white)
                .cornerRadius(4)
                .shadow(color: Color(hex: "#191919").opacity(0.12), radius: 20, x: 0, y: 0)
            }

            Spacer()

            Button(action: {
                Task {
                    guard let selectedId else { return }
                    await viewModel.updateIndustry(id: selectedId)
                    await viewModel.fetchuserInfo()
                    await MainActor.run {
                        viewModel.showIndustryToast = true
                    }
                    router.pop()
                }
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedId != viewModel.user?.industryId
                        ? Color.primaryNormal
                        : Color(hex: "#EBEBEB")
                    )
                    .foregroundColor(
                        selectedId != viewModel.user?.industryId
                        ? .white
                        : Color(hex: "#BDBDBD")
                    )
                    .cornerRadius(4)
            }
            .disabled(selectedId == viewModel.user?.industryId)
        }
        .onAppear {
            Task {
                // 사용자 정보 로드 후 현재 선택된 종사산업으로 초기화
                await viewModel.fetchuserInfo()
                selectedId = viewModel.user?.industryId
            }
        }
        .padding(20)
        .navigationBarTitleDisplayMode(.inline)
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
                Text("종사 산업 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
