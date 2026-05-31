//
//  SortBottomSheet.swift
//  Explore
//
//  Created by 권민재 on 4/28/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem
import ExploreDomain

struct SortBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var orderOpt: ExploreOrderOption
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
                .accessibilityLabel("닫기")
                .accessibilityIdentifier("sort_close_button")
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(ExploreOrderOption.allCases, id: \.self) { option in
                    Button(action: {
                        orderOpt = option
                        Task {
                            await onSelect()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 0) {
                            Text(option.displayText)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color.captionStrong)
                            Spacer()
                            if orderOpt == option {
                                Image(asset: DesignSystemAsset.lineCheckmark)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.primaryNormal)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                    }
                    .accessibilityLabel("\(option.displayText)\(orderOpt == option ? ", 선택됨" : "")")
                    .accessibilityIdentifier("sort_option_\(option.rawValue)")

                    if option != ExploreOrderOption.allCases.last {
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
