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

public struct OverlayRootView<Content: View>: View {
    @ObservedObject private var networkManager = NetworkStatusManager.shared
    @ViewBuilder let content: Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    private var isPopupPresented: Binding<Bool> {
        Binding(
            get: { !networkManager.isConnected },
            set: { _ in }
        )
    }

    public var body: some View {
        ZStack {
            content
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



final class NetworkStatusManager: ObservableObject {
    static let shared = NetworkStatusManager()

    @Published var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
