//
//  Wrap.swift
//  Mypage
//
//  Created by 권민재 on 5/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem

struct Wrap: View {
    let tags: [String]
    var onAdd: (() -> Void)?

    var body: some View {
        let tagList = onAdd != nil ? tags + ["__ADD__"] : tags

        FlexibleView(
            data: tagList,
            spacing: 8
        ) { tag in
            if tag == "__ADD__" {
                Button(action: {
                    onAdd?()
                }) {
                    Image(asset: DesignSystemAsset.linePlus)
                        .renderingMode(.template)
                        .resizable()
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.primaryNormal)
                }
                .frame(width: 30, height: 30)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.primaryNormal, lineWidth: 1)
                )
            } else {
                Text(tag)
                    .font(.hanSansNeo(14, .medium))
                    .frame(height: 20)
                    .foregroundStyle(Color.captionBody)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(.white)
                    .clipShape(Capsule())
                    .overlay {
                        Capsule()
                            .stroke(Color.captionDisabled, lineWidth: 1)
                    }
            }
        }
    }
}
