import SwiftUI
import NetworkKit
import Shared
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics

@main
struct NewdokApp: App {
    @State private var showUpdatePopup = false
    @State private var coordinator = AppCoordinator()
    private let container: AppContainer

    init() {
        FirebaseApp.configure()
        #if DEBUG
        ErrorLoggerRegistry.register(DefaultErrorLogger())        // 로컬 로깅만 (Crashlytics 오염 방지)
        #else
        ErrorLoggerRegistry.register(CrashlyticsErrorLogger())    // 로컬 + Crashlytics non-fatal
        #endif
        AppErrorMapperRegistry.register(NetworkErrorAppMapper())
        TokenStore.shared.migrateTokenIfNeeded()

        self.container = AppContainer(deps: AppDependencies())
    }

    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppRootView(container: container, coordinator: coordinator)
            }
            .hideKeyboardOnTap()
            .overlay(
                AppToastHost()
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
