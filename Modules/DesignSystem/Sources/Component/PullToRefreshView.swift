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

    @State private var startOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var hasTriggered = false

    public init(
        threshold: CGFloat = 80,
        @ViewBuilder content: () -> Content,
        @ViewBuilder animationView: @escaping () -> AnyView,
        onRefresh: @escaping () async -> Void
    ) {
        self.content = content()
        self.threshold = threshold
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
                        print("🔄 [PullToRefresh] Triggering refresh! dragDistance: \(dragDistance)")
                        
                        // 햅틱 진동 추가
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        hasTriggered = true
                        isRefreshing = true
                        
                        // API 호출을 약간 지연시켜 사용자 경험 개선
                        Task {
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 지연
                            await onRefresh()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isRefreshing = false
                            }
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
