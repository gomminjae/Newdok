//
//  AppState.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//

import Foundation
import Combine


public enum AuthState {
    case guest
    case authenticated
}

// MARK: - Centralized Data Clearing Service
public final class DataClearingService: ObservableObject {
    public static let shared = DataClearingService()
    
    private var clearables: [() -> Void] = []
    
    private init() {
        print("🔧 [DataClearingService] 초기화됨")
        setupNotificationObservers()
    }
    
    public func register(_ clearAction: @escaping () -> Void) {
        clearables.append(clearAction)
        print("📝 [DataClearingService] 등록됨 - 총 \(clearables.count)개")
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .didLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("🚪 [DataClearingService] 로그아웃 알림 수신")
            self?.clearAllData()
        }
        
        NotificationCenter.default.addObserver(
            forName: .didSwitchToGuest,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("👤 [DataClearingService] 게스트 전환 알림 수신")
            self?.clearAllData()
        }
    }
    
    private func clearAllData() {
        print("🧹 [DataClearingService] 데이터 초기화 시작 - \(clearables.count)개")
        clearables.forEach { clearAction in
            clearAction()
        }
        print("✅ [DataClearingService] 데이터 초기화 완료")
    }
}

public final class AppState: ObservableObject {
    
    @Published public var authState: AuthState = .guest
    
    public static let shared = AppState()
    
    private init() {}
    
    public func logout() {
        print("🚪 [AppState] 로그아웃 시작")
        // AppStorage 초기화
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "isGuest")
        UserDefaults.standard.removeObject(forKey: "nickname")
        UserDefaults.standard.removeObject(forKey: "email")
        
        // 인증 상태 변경
        authState = .guest
        
        // NotificationCenter로 로그아웃 알림
        NotificationCenter.default.post(name: .didLogout, object: nil)
        print("🚪 [AppState] 로그아웃 완료 - 알림 발송됨")
    }
    
    public func switchToGuest() {
        print("👤 [AppState] 게스트 전환 시작")
        // AppStorage 초기화
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.set(true, forKey: "isGuest")
        UserDefaults.standard.removeObject(forKey: "nickname")
        UserDefaults.standard.removeObject(forKey: "email")
        
        // 인증 상태 변경
        authState = .guest
        
        // NotificationCenter로 게스트 전환 알림
        NotificationCenter.default.post(name: .didSwitchToGuest, object: nil)
        print("👤 [AppState] 게스트 전환 완료 - 알림 발송됨")
    }
}

// MARK: - Notification Names
public extension Notification.Name {
    static let didLogout = Notification.Name("didLogout")
    static let didSwitchToGuest = Notification.Name("didSwitchToGuest")
}
