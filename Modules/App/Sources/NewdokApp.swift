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
            .onAppear(perform: checkVersion)
            .alert(isPresented: $showUpdateAlert) {
                Alert(
                    title: Text("업데이트 안내"),
                    message: Text("새로운 버전이 출시되었습니다. 스토어로 이동하여 업데이트를 진행해주세요."),
                    primaryButton: .default(Text("업데이트"), action: {
                        openAppStore()
                    }),
                    secondaryButton: .cancel(Text("나중에"))
                )
            }
        }
    }
    
    private func checkVersion() {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let appStoreVersion = results.first?["version"] as? String,
                  let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                return
            }
            
            if appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                DispatchQueue.main.async {
                    showUpdateAlert = true
                }
            }
        }.resume()
    }
    
    private func openAppStore() {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/\(bundleId)") else {
            return
        }
        UIApplication.shared.open(url)
    }
}
