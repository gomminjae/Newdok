//
//  ToastModifier.swift
//  DesignSystem
//
//  Created by 권민재 on 4/20/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI

public struct ToastView: View {
    public let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                
                .font(.system(size: 14))
                .foregroundColor(.white)

            Text(message)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(.white)
                .onAppear {
                    print("🔍 [ToastView] 메시지 표시: '\(message)'")
                }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color(hex: "#2866D3"))
        .cornerRadius(8)
        .padding(.horizontal, 24)
    }
}
