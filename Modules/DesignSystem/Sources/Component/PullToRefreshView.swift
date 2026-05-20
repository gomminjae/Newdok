//
//  PullToRefreshView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/8/25.
//

import SwiftUI

public struct PullToRefreshView<Content: View, Animation: View>: View {
    let content: Content
    let threshold: CGFloat
    let onRefresh: () async -> Void
    let animationView: () -> Animation
    let cooldownInterval: TimeInterval

    @State private var startOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var hasTriggered = false
    @State private var lastRefreshTime = Date.distantPast

    public init(
        threshold: CGFloat = 80,
        cooldownInterval: TimeInterval = 1.5,
        @ViewBuilder content: () -> Content,
        @ViewBuilder animationView: @escaping () -> Animation,
        onRefresh: @escaping () async -> Void
    ) {
        self.content = content()
        self.threshold = threshold
        self.cooldownInterval = cooldownInterval
        self.animationView = animationView
        self.onRefresh = onRefresh
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            GeometryReader { geo -> Color in
                let offset = geo.frame(in: .global).minY

                DispatchQueue.main.async {
                    if startOffset == 0 {
                        startOffset = offset
                    }

                    let dragDistance = offset - startOffset

                    if dragDistance > 0 {
                        hasTriggered = false
                    }

                    if !isRefreshing && !hasTriggered && dragDistance > threshold {
                        let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
                        if timeSinceLastRefresh < cooldownInterval {
                            return
                        }

                        hasTriggered = true
                        isRefreshing = true
                        lastRefreshTime = Date()

                        Task {
                            await onRefresh()
                            isRefreshing = false
                        }
                    }
                }

                return Color.clear
            }
            .frame(height: 0)

            if isRefreshing {
                animationView()
                    .frame(height: 60)
            }

            content
        }
    }
}
