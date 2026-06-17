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
            if isRefreshing {
                animationView()
                    .frame(height: 60)
                    .transition(.opacity)
            }
            content
        }
        .scrollBounceBehavior(.always, axes: .vertical)
        .animation(.easeInOut(duration: 0.2), value: isRefreshing)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y + geometry.contentInsets.top
        } action: { _, offset in
            handleOverscroll(-offset)
        }
        .accessibilityHint("당겨서 새로고침")
    }

    private func handleOverscroll(_ distance: CGFloat) {
        if distance <= 0 {
            hasTriggered = false
        }

        guard !isRefreshing, !hasTriggered, distance > threshold else { return }
        guard Date().timeIntervalSince(lastRefreshTime) >= cooldownInterval else { return }

        hasTriggered = true
        isRefreshing = true
        lastRefreshTime = Date()

        Task { @MainActor in
            await onRefresh()
            isRefreshing = false
        }
    }
}
