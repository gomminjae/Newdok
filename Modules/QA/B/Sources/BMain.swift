


import SwiftUI
import AppCoordinator
import DesignSystem
import Shared


@main
struct BApp: App {
    
    @State private var isLaunch: Bool = true
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    
    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
    
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorEntry.makeAFlow()
                .environmentObject(router)
                .environmentObject(tabSelection)
        }
    }
}
