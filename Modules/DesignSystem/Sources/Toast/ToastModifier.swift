//
//  ToastModifier.swift
//  DesignSystem
//
//  Created by 권민재 on 4/20/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct ToastView: View {
    let message: String

    public var body: some View {
        HStack(spacing: 10) {
            Image(asset: DesignSystemAsset.lineCheckCircle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)

            Text(message)
                .foregroundColor(.white)
                .font(.hanSansNeo(14, .medium))
        }
        .padding()
        .background(Color.primaryNormal)
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}


public struct BottomToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval

    public func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation {
                                    isPresented = false
                                }
                            }
                        }
                }
                .animation(.easeInOut, value: isPresented)
            }
        }
    }
}
public extension View {
    func bottomToast(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 2.0) -> some View {
        self.modifier(BottomToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
