import SwiftUI
import NetworkKit
import Shared
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics
import KakaoSDKCommon
import KakaoSDKAuth

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

        if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        }

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
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    AuthController.handleOpenUrl(url: url)
                }
            }
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
