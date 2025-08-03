//
//  LottieView 2.swift
//  DesignSystem
//
//  Created by 권민재 on 8/2/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI
import Lottie

// MARK: - LottieAsset (Lottie 파일용 타입)

public struct LottieAsset {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public var animation: LottieAnimation? {
        LottieAnimation.named(name)
    }
}

// MARK: - LottieView

public struct LottieView: UIViewRepresentable {
    let lottieAsset: LottieAsset
    let loopMode: LottieLoopMode
    let contentMode: UIView.ContentMode
    
    public init(
        lottieAsset: LottieAsset,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) {
        self.lottieAsset = lottieAsset
        self.loopMode = loopMode
        self.contentMode = contentMode
    }
    
    // 기존 name 기반 초기화도 지원
    public init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) {
        self.lottieAsset = LottieAsset(name: name)
        self.loopMode = loopMode
        self.contentMode = contentMode
    }

    public func makeUIView(context: Context) -> LottieAnimationView {
        guard let animation = lottieAsset.animation else {
            fatalError("Unable to load Lottie animation '\(lottieAsset.name)'")
        }

        let view = LottieAnimationView(animation: animation)
        view.loopMode = loopMode
        view.contentMode = contentMode
        view.play()
        return view
    }

    public func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

// MARK: - Lottie 확장 (폰트 확장과 유사한 방식)

public extension LottieAsset {
    static let loading = LottieAsset(name: "loading")
}

public extension LottieView {
    static func loading() -> LottieView {
        LottieView(lottieAsset: .loading)
    }
    
    static func loading(loopMode: LottieLoopMode = .loop) -> LottieView {
        LottieView(lottieAsset: .loading, loopMode: loopMode)
    }
}

// MARK: - LoadingAnimationView

public struct LoadingAnimationView: View {
    @State private var animating = false

    public init() {}

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { index in
                LottieView.loading()
                    .frame(width: 16, height: 16)
                    .opacity(animating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.1), value: animating)
            }
        }
        .onAppear {
            animating = true
        }
    }
}


// MARK: - PullToRefreshView

public enum PullToRefreshState {
    case idle
    case pulling(progress: CGFloat)
    case refreshing
}

public struct PullToRefreshView<Content: View>: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () async -> Void
    let content: Content
    @ViewBuilder let animationViewBuilder: (PullToRefreshState) -> AnyView

    @State private var refreshOffset: CGFloat = 0
    @State private var isDragging = false

    public init(
        isRefreshing: Binding<Bool>,
        onRefresh: @escaping () async -> Void,
        @ViewBuilder animationViewBuilder: @escaping (PullToRefreshState) -> AnyView,
        @ViewBuilder content: () -> Content
    ) {
        self._isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.animationViewBuilder = animationViewBuilder
        self.content = content()
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    let animView = animationViewBuilder(currentState)
                    animView
                        .frame(height: max(0, refreshOffset))
                        .opacity(refreshOffset > 0 ? 1 : 0)

                    content
                }
                .background(
                    GeometryReader { inner in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: inner.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                handleScrollOffset(offset)
            }
        }
    }

    private var currentState: PullToRefreshState {
        if isRefreshing {
            return .refreshing
        } else if refreshOffset > 0 {
            return .pulling(progress: min(refreshOffset / 100, 1.0))
        } else {
            return .idle
        }
    }

    private func handleScrollOffset(_ offset: CGFloat) {
        let threshold: CGFloat = 100

        if offset > 0 && !isRefreshing {
            refreshOffset = offset
            isDragging = true
        } else if offset <= 0 {
            if isDragging && refreshOffset > threshold && !isRefreshing {
                isRefreshing = true
                Task {
                    await onRefresh()
                    isRefreshing = false
                }
            }
            refreshOffset = 0
            isDragging = false
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


// MARK: - Convenience init for Lottie pull-to-refresh

public extension PullToRefreshView {
    init(
        isRefreshing: Binding<Bool>,
        onRefresh: @escaping () async -> Void,
        lottieAnimation: @escaping () -> AnyView,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            isRefreshing: isRefreshing,
            onRefresh: onRefresh,
            animationViewBuilder: { state in
                switch state {
                case .idle:
                    return AnyView(Color.clear)
                case .pulling(let progress):
                    return AnyView(
                        lottieAnimation()
                            .scaleEffect(0.5 + progress * 0.5)
                            .opacity(progress)
                    )
                case .refreshing:
                    return lottieAnimation()
                }
            },
            content: content
        )
    }
}


// MARK: - Preview

#Preview {
    VStack {
        PullToRefreshView(
            isRefreshing: .constant(false),
            onRefresh: { print("Refreshing...") },
            lottieAnimation: { AnyView(LottieView(name: "loading")) }
        ) {
            ForEach(0..<20) {
                Text("Item \($0)")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
    }
}
