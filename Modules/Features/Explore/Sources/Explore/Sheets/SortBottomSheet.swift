//
//  SortBottomSheet.swift
//  Explore
//
//  Created by 권민재 on 4/28/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem

struct SortBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    let sortOptions: [(text: String, value: String)] = [
        ("인기순", "인기순"),
        ("최신등록순", "최신순")
    ]
    @Binding var orderOpt: String?
    var onSelect: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

            HStack {
                Text("정렬")
                    .font(.hanSansNeo(20, .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(sortOptions, id: \.value) { option in
                    Button(action: {
                        orderOpt = option.value
                        Task {
                            await onSelect()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 0) {
                            Text(option.text)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color(hex: "363636"))
                            Spacer()
                            if orderOpt == option.value {
                                Image(asset: DesignSystemAsset.lineCheckmark)
                                    .renderingMode(.template)
                                    .foregroundColor(Color(hex: "#2866D3"))
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                    }
                    
                    if option.value != sortOptions.last?.value {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
            .padding(.top, 28)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.hidden)
        .edgesIgnoringSafeArea(.horizontal)
    }
}
