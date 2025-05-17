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

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: MypageViewModel

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
        self._selectedId = State(initialValue: viewModel.user?.industryId)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종사 산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))

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
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(height: 48)
                .background(.white)
                .cornerRadius(6)
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "C0C0C0"))
                }
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
                                        .foregroundColor(item.id == selectedId ? .primaryNormal : Color(hex: "363636"))
                                        .font(.hanSansNeo(14, .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                                .background(
                                    item.id == selectedId
                                        ? Color.primaryNormal.opacity(0.1)
                                        : Color.white
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 240)
                .background(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "C0C0C0")))
            }

            Spacer()

            Button(action: {
                Task {
                    guard let selectedId else { return }
                    await viewModel.updateIndustry(id: selectedId)
                    viewModel.showIndustryToast = true
                    dismiss()
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
        .padding(20)
        .navigationBarTitleDisplayMode(.inline)
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
                Text("종사 산업 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
