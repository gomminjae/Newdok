import SwiftUI
import NetworkKit
import Shared
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics
import FirebaseCrashlytics
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct NewdokApp: App {
    @State private var showUpdatePopup = false
    @State private var appRouter = AppRouter()
    private let container: AppContainer

    init() {
        FirebaseApp.configure()
        guard let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String,
              !kakaoAppKey.isEmpty, !kakaoAppKey.hasPrefix("$(") else {
            fatalError("KAKAO_NATIVE_APP_KEY가 치환되지 않았습니다. xcconfig 변수 설정을 확인하세요.")
        }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
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
                AppRootView(container: container, appRouter: appRouter)
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
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
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
