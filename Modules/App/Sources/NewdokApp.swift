import SwiftUI
import Core
import Shared
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics

@main
struct NewdokApp: App {
    @State private var showUpdateAlert = false
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()
    private let container: AppContainer

    init() {
        FirebaseApp.configure()
        DesignSystemFontFamily.registerAllCustomFonts()
        ErrorLoggerRegistry.register(CoreErrorLogger())
        TokenStorage.migrateTokenIfNeeded()

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
            .alert(isPresented: $showUpdateAlert) {
                Alert(
                    title: Text("업데이트 안내"),
                    message: Text("새로운 버전이 출시되었습니다. 스토어로 이동하여 업데이트를 진행해주세요."),
                    primaryButton: .default(Text("업데이트"), action: {
                        VersionCheckService.shared.openAppStore()
                    }),
                    secondaryButton: .cancel(Text("나중에"))
                )
            }
        }
    }

    private func checkVersion() async {
        let needsUpdate = await VersionCheckService.shared.checkForUpdate()
        if needsUpdate {
            showUpdateAlert = true
        }
    }
}
