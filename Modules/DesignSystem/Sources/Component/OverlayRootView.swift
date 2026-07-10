//
//  OverlayRootView.swift
//  DesignSystem
//
//  Created by 권민재 on 6/27/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI
import Network
import Shared
import PopupView
import Observation

public struct OverlayRootView<Content: View>: View {
    private var networkManager = NetworkStatusManager.shared
    private let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    private var isPopupPresented: Binding<Bool> {
        Binding(
            get: { !networkManager.isConnected },
            set: { _ in }
        )
    }

    public var body: some View {
        ZStack {
            content()
        }
        .popup(isPresented: isPopupPresented) {
            NetworkErrorView()
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .closeOnTap(true)
                .backgroundColor(Color.black.opacity(0.3))
        }
    }
}

@Observable
@MainActor
final class NetworkStatusManager {
    static let shared = NetworkStatusManager()

    var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { path in
            let connected = (path.status == .satisfied)
            Task { @MainActor in
                NetworkStatusManager.shared.isConnected = connected
            }
        }
        monitor.start(queue: queue)
    }

    func checkNetworkStatus() {
        // 일회용 모니터로 최신 네트워크 상태를 확인
        let probe = NWPathMonitor()
        probe.pathUpdateHandler = { path in
            probe.cancel()
            let connected = (path.status == .satisfied)
            Task { @MainActor in
                NetworkStatusManager.shared.isConnected = connected
            }
        }
        probe.start(queue: queue)
    }
}
