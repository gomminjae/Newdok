//
//  NewdokApp.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//

import SwiftUI
import Core
import Shared
import AppCoordinator
import DesignSystem
import PopupView
@main
struct NewdokApp: App {

    @State private var showUpdateAlert = false
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var exploreIntent = ExploreIntent()

    init() {
        // DesignSystem 폰트 등록
        DesignSystemFontFamily.registerAllCustomFonts()
    }



    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppCoordinatorEntry.makeAFlow(router: router, exploreIntent: exploreIntent)
            }
            .environmentObject(router)
            .environmentObject(tabSelection)
            .environmentObject(exploreIntent)
            .environmentObject(ToastCenter.shared)
            // ToastHost가 상위에서 환경 객체를 못 물려받는 경우가 있어 직접 주입
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
