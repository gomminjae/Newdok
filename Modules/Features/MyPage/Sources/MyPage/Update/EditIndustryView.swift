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

public struct EditIndustryView: View {
    @State private var selectedId: Int?

    @Environment(MypageViewModel.self) private var viewModel
    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종사 산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .allowsHitTesting(false) // 터치 불가능하게 설정

            DropdownSelector(
                placeholder: "선택해주세요",
                options: viewModel.industries.map { DropdownOption(key: "\($0.id)", value: $0.name) },
                onOptionSelected: { selectedId = Int($0.key) },
                selectedKey: selectedId.map(String.init)
            )

            Spacer()

            Button(action: {
                Task { @MainActor in
                    guard let selectedId else { return }
                    let didUpdate = await viewModel.updateIndustry(id: selectedId)
                    guard didUpdate else { return }
                    await viewModel.fetchuserInfo()
                    onBack()
                    try await Task.sleep(nanoseconds: 150_000_000)
                    ToastCenter.shared.show("종사산업이 변경되었습니다.")
                }
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedId != viewModel.user?.industryId
                        ? Color.primaryNormal
                        : Color.lineNeutral
                    )
                    .foregroundColor(
                        selectedId != viewModel.user?.industryId
                        ? .white
                        : Color.grayLight
                    )
                    .cornerRadius(4)
            }
            .disabled(selectedId == viewModel.user?.industryId || viewModel.isIndustryUpdating)
        }
        .onAppear {
            // 싱글톤 VM에 이미 user 데이터가 있으면 바로 사용
            if viewModel.user != nil {
                selectedId = viewModel.user?.industryId
            } else {
                Task {
                    await viewModel.fetchuserInfo()
                    selectedId = viewModel.user?.industryId
                }
            }
        }
        .padding(20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                Text("종사 산업 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .onChange(of: viewModel.showIndustrySuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "종사산업이 변경되었습니다.")
                viewModel.showIndustrySuccess = false
            }
        }
    }
}
