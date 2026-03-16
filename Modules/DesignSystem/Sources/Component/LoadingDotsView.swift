//
//  LoadingDotsView.swift
//  DesignSystem
//
//  Created by 권민재 on 3/9/26.
//

import SwiftUI

public struct LoadingDotsView: View {
    @State private var activeDot = 0

    private let dotCount = 3
    private let dotSize: CGFloat
    private let activeColor: Color
    private let inactiveColor: Color
    private let spacing: CGFloat

    public init(
        dotSize: CGFloat = 6,
        activeColor: Color = Color.primaryStrong,
        inactiveColor: Color = Color.primarySoft,
        spacing: CGFloat = 4
    ) {
        self.dotSize = dotSize
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.spacing = spacing
    }

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(index == activeDot ? activeColor : inactiveColor)
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: activeDot)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        activeDot = 0
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(400))
                activeDot = (activeDot + 1) % dotCount
            }
        }
    }
}
