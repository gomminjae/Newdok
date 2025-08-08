//
//  PullToRefreshView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/8/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI


public struct PullToRefreshView<Content: View>: View {
    let content: Content
    let threshold: CGFloat
    let onRefresh: () async -> Void
    let animationView: () -> AnyView
    let cooldownInterval: TimeInterval // 새로고침 간격 제한 (초)

    @State private var startOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var hasTriggered = false
    @State private var lastRefreshTime: Date = Date.distantPast

    public init(
        threshold: CGFloat = 80,
        cooldownInterval: TimeInterval = 1.5, // 기본 1.5초 제한으로 조절
        @ViewBuilder content: () -> Content,
        @ViewBuilder animationView: @escaping () -> AnyView,
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
                    print("🔄 [PullToRefresh] offset: \(offset), dragDistance: \(dragDistance), threshold: \(threshold), isRefreshing: \(isRefreshing), hasTriggered: \(hasTriggered)")
                    
                    // 스크롤이 시작되면 hasTriggered 리셋
                    if dragDistance > 0 {
                        hasTriggered = false
                    }
                    
                    // 임계값을 넘고 아직 트리거되지 않았을 때만 실행
                    if !isRefreshing && !hasTriggered && dragDistance > threshold {
                        // 시간 제한 확인
                        let timeSinceLastRefresh = Date().timeIntervalSince(lastRefreshTime)
                        if timeSinceLastRefresh < cooldownInterval {
                            print("🔄 [PullToRefresh] Cooldown active: \(timeSinceLastRefresh)s / \(cooldownInterval)s")
                            return
                        }
                        
                        print("🔄 [PullToRefresh] Triggering refresh! dragDistance: \(dragDistance)")
                        
                        hasTriggered = true
                        isRefreshing = true
                        lastRefreshTime = Date()
                        
                        // API 호출을 약간 지연시켜 사용자 경험 개선
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
