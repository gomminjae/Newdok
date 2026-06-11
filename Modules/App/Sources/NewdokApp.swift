import SwiftUI
import NetworkKit
import Shared
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics

@main
struct NewdokApp: App {
    @State private var showUpdatePopup = false
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()
    private let container: AppContainer

    init() {
        FirebaseApp.configure()
        ErrorLoggerRegistry.register(DefaultErrorLogger())
        AppErrorMapperRegistry.register(NetworkErrorAppMapper())
        TokenStore.shared.migrateTokenIfNeeded()

        let router = AppRouter()
        self._router = State(initialValue: router)
        self.container = AppContainer(router: router, deps: AppDependencies())
    }

    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppRootView(router: router, container: container)
            }
            .hideKeyboardOnTap()
            .environment(router)
            .environment(tabSelection)
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
            .overlay(
                AppToastHost()
                    .environment(ToastCenter.shared)
                    .allowsHitTesting(false)
            )
            .task {
                await checkVersion()
            }
            .updateAvailablePopup(isPresented: $showUpdatePopup) {
                VersionCheckService.shared.openAppStore()
            }
        }
    }

    private func checkVersion() async {
        let needsUpdate = await VersionCheckService.shared.checkForUpdate()
        if needsUpdate {
            showUpdatePopup = true
        }
    }
}
