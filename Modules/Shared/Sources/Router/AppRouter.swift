//
//  AppRouter.swift
//  Shared
//
//  Created by 권민재 on 4/9/25.
//
import SwiftUI


@MainActor
public final class AppRouter: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var root: AppRoute = .onboarding
    
    // 스와이프 백 중복 방지를 위한 상태 관리
    private var isProcessingSwipeBack = false
    private var lastSwipeBackTime: Date = Date.distantPast
    private let swipeBackCooldown: TimeInterval = 0.5 // 0.5초 쿨다운

    public init() {
        // Swipe back 알림 리스너 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSwipeBack),
            name: .init("SwipeBack"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func push(_ route: AppRoute) {
        path.append(route)
        print("🔄 [AppRouter] Push: \(route) - 스택 크기: \(path.count)")
    }

    public func pop() {
        guard !path.isEmpty else { 
            print("⚠️ [AppRouter] Pop 실패: 스택이 비어있음")
            return 
        }
        path.removeLast()
        print("🔄 [AppRouter] Pop 완료 - 스택 크기: \(path.count)")
    }

    public func resetTo(_ route: AppRoute) {
        path = NavigationPath()
        root = route
        print("🔄 [AppRouter] Reset to: \(route)")
    }

    public func reset() {
        path = NavigationPath()
        print("🔄 [AppRouter] Reset 완료")
    }
    
    @objc private func handleSwipeBack() {
        let now = Date()
        
        // 중복 처리 방지
        guard !isProcessingSwipeBack else {
            print("⚠️ [AppRouter] Swipe back 중복 처리 방지")
            return
        }
        
        // 쿨다운 체크
        guard now.timeIntervalSince(lastSwipeBackTime) >= swipeBackCooldown else {
            print("⚠️ [AppRouter] Swipe back 쿨다운 중")
            return
        }
        
        isProcessingSwipeBack = true
        lastSwipeBackTime = now
        
        print("🔄 [AppRouter] Swipe back 처리 시작 - 스택 크기: \(path.count)")
        
        pop()
        
        // 처리 완료 후 플래그 리셋
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isProcessingSwipeBack = false
        }
    }
}
