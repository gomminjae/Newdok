//
//  ServerErrorPopupView.swift
//  DesignSystem
//
//  Created by 권민재 on 3/2/26.
//

import SwiftUI
import Shared

public struct ServerErrorPopupView: View {
    public let onGoBack: (() -> Void)?
    public let onRetry: () -> Void

    public init(onGoBack: (() -> Void)? = nil, onRetry: @escaping () -> Void) {
        self.onGoBack = onGoBack
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 20)

            Text("일시적인 오류가 발생했습니다.")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color.captionHeavy)
                .padding(.top, 6)

            Text("새로고침을 눌러 다시 시도해 주세요.\n문제가 계속되면 서비스 피드백을 통해\n문의해 주세요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.top, 6)

            if let onGoBack = onGoBack {
                HStack(spacing: 8) {
                    Button(action: onGoBack) {
                        Text("이전으로")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(Color.captionNeutral)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.lineNeutral))
                    }
                    .accessibilityLabel("이전으로")
                    .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.serverErrorBack)

                    Button(action: onRetry) {
                        Text("새로고침")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.primaryNormal)
                            .cornerRadius(4)
                    }
                    .accessibilityLabel("새로고침")
                    .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.serverErrorRefresh)
                }
                .padding(.top, 24)
                .padding(.bottom, 28)
                .padding(.horizontal, 24)
            } else {
                Button(action: onRetry) {
                    Text("새로고침")
                        .font(.hanSansNeo(14, .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .foregroundStyle(Color.white)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
                .accessibilityLabel("새로고침")
                .accessibilityIdentifier(AccessibilityID.DesignSystem.Popup.serverErrorRefresh)
                .padding(.top, 24)
                .padding(.bottom, 28)
                .padding(.horizontal, 24)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    ServerErrorPopupView(onGoBack: {}, onRetry: {})
}
