import SwiftUI
import Core
import Shared
import AppCoordinator
import DesignSystem
import PopupView
import FirebaseCore
import FirebaseAnalytics

@main
struct NewdokApp: App {
    @State private var showUpdateAlert = false
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var exploreIntent = ExploreIntent()

    init() {
        FirebaseApp.configure()
        DesignSystemFontFamily.registerAllCustomFonts()
        ErrorLoggerRegistry.register(CoreErrorLogger())
    }

    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppCoordinatorEntry.makeAFlow(
                    router: router,
                    exploreIntent: exploreIntent,
                    factories: FeatureFactories(
                        auth: CompositionRoot.makeAuthFactory(),
                        home: CompositionRoot.makeHomeFactory(),
                        explore: CompositionRoot.makeExploreFactory(),
                        subscribe: CompositionRoot.makeSubscribeFactory(),
                        bookmark: CompositionRoot.makeBookmarkFactory(),
                        detail: CompositionRoot.makeDetailFactory(),
                        search: CompositionRoot.makeSearchFactory(),
                        mypage: CompositionRoot.makeMypageFactory(),
                        launch: CompositionRoot.makeLaunchFactory()
                    )
                )
            }
            .hideKeyboardOnTap()
            .environmentObject(router)
            .environmentObject(tabSelection)
            .environmentObject(exploreIntent)
            .environmentObject(ToastCenter.shared)
            .overlay(
                AppToastHost()
                    .environmentObject(ToastCenter.shared)
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
