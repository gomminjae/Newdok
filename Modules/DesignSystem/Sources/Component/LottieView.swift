//
//  LottieView 2.swift
//  DesignSystem
//
//  Created by 권민재 on 8/2/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI
import Lottie

public struct PTRView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { index in
                LottieView(animation: .named("ptr"))
                    .playing()
                    .frame(width: 40, height: 40)
            }
        }
    }
}


