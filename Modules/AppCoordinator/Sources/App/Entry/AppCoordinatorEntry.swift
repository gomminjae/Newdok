//
//  AppCoordinatorEntry.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//
import SwiftUI
import Shared

public enum AppCoordinatorEntry {

    /// Returns the main application flow used by both the production
    /// and QA applications.
    @MainActor
    public static func makeRootView() -> some View {
        QABRootView()
    }

    /// Deprecated: use ``makeRootView()`` instead.
    @available(*, deprecated, renamed: "makeRootView")
    @MainActor
    public static func makeAFlow() -> some View {
        makeRootView()
    }
}


