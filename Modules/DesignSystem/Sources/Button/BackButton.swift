//
//  BackButton.swift
//  DesignSystem
//
//  Created by 권민재 on 4/6/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI

public struct BackButton: View {
    var action: () -> Void  // 외부에서 전달받은 액션

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: {
            // 액션을 호출
            action()
        }) {
            HStack(spacing: 4) {
                Image(asset: DesignSystemAsset.back)  // 뒤로 가기 아이콘
                    .imageScale(.large)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 4)
        }
        .accessibilityLabel("뒤로가기")
        .accessibilityIdentifier("back_button")
    }
}
