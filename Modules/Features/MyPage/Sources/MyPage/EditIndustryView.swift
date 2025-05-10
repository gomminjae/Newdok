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
    @Binding var selectedIndustryId: Int?
    @State private var isExpanded: Bool = false
    
    
    @Environment(\.dismiss) private var dismiss

    public init(selectedIndustryId: Binding<Int?>) {
        self._selectedIndustryId = selectedIndustryId
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("종사 산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))

            // 드롭다운 버튼
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(
                        SelectableItemStore.shared.name(
                            for: selectedIndustryId ?? -1,
                            in: .industry
                        ).isEmpty ? "선택해주세요" :
                        SelectableItemStore.shared.name(for: selectedIndustryId ?? -1, in: .industry)
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
                                selectedIndustryId = item.id
                                isExpanded = false
                            } label: {
                                HStack {
                                    Text(item.name)
                                        .foregroundColor(item.id == selectedIndustryId ? .primaryNormal : Color(hex: "363636"))
                                        .font(.hanSansNeo(14, .medium))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 20)
                                .background(
                                    item.id == selectedIndustryId ?
                                    Color.primaryNormal.opacity(0.1) :
                                    Color.white
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 48 * 5) // 5개 항목 높이 제한
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(hex: "C0C0C0"))
                )
            }


            Spacer()
            
            
            Button(action: {
                
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .padding(20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 왼쪽 백버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }

            // 가운데 타이틀
            ToolbarItem(placement: .principal) {
                Text("종사 산업 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
