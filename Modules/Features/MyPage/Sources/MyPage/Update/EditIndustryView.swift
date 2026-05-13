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

    @Environment(MypageViewModel.self) private var viewModel
    @Environment(ToastCenter.self) private var toast
    @Environment(AppRouter.self) private var router

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종사 산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .allowsHitTesting(false) // 터치 불가능하게 설정

            Button(action: {
                withAnimation { isExpanded.toggle() }
            }) {
                HStack {
                    Text(
                        viewModel.industryName(for: selectedId ?? -1)
                            .ifEmpty("선택해주세요")
                    )
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionStrong)

                    Spacer()
                    Image(asset: isExpanded ? DesignSystemAsset.lineUp : DesignSystemAsset.lineDown)
                        .foregroundColor(Color.captionStrong)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(.white)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isExpanded ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
                )
            }

            if isExpanded {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.industries, id: \.id) { item in
                            Button {
                                selectedId = item.id
                                isExpanded = false
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundColor(item.id == selectedId ? Color.primaryNormal : Color.captionStrong)
                                        .font(.hanSansNeo(14, .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(
                                    item.id == selectedId
                                        ? Color.primaryBgLight
                                        : Color.white
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
                .background(Color.white)
                .cornerRadius(4)
                .shadow(color: Color.captionDark.opacity(0.12), radius: 20, x: 0, y: 0)
            }

            Spacer()

            Button(action: {
                Task { @MainActor in
                    guard let selectedId else { return }
                    await viewModel.updateIndustry(id: selectedId)
                    await viewModel.fetchuserInfo()
                    router.pop()
                    try? await Task.sleep(nanoseconds: 150_000_000)
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
            .disabled(selectedId == viewModel.user?.industryId)
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
        .onChange(of: viewModel.showIndustrySuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "종사산업이 변경되었습니다.")
                viewModel.showIndustrySuccess = false
            }
        }
    }
}
