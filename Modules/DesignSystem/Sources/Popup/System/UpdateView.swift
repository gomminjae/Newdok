//
//  UpdateView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/23/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import PopupView

public struct UpdateView: View {
    public let onUpdate: () -> Void

    public init(onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.systemPost)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 20)
            Text("최신 버전 업데이트가 있습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color.captionHeavy)
                .padding(.top, 6)
            Text("안정적인 서비스 사용을 위해\n최신 버전으로 업데이트를 진행해 주세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .multilineTextAlignment(.center)
                .padding(.top, 6)
            Button(action: onUpdate) {
                Text("업데이트")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .accessibilityLabel("업데이트")
            .accessibilityIdentifier("update_confirm_button")
            .padding(.top, 24)
            .padding(.bottom, 28)
            .padding(.horizontal, 24)
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

public extension View {
    func updateAvailablePopup(
        isPresented: Binding<Bool>,
        onUpdate: @escaping () -> Void
    ) -> some View {
        popup(isPresented: isPresented) {
            UpdateView(
                onUpdate: {
                    isPresented.wrappedValue = false
                    onUpdate()
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
                .allowTapThroughBG(false)
        }
    }
}

#Preview {
    UpdateView(onUpdate: {})
}
