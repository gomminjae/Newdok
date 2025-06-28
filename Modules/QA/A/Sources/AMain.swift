
import SwiftUI
import AppCoordinator
import DesignSystem
import Shared




@main
struct AApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()

    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
    
    
    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppCoordinatorEntry.makeAFlow()
                    .environmentObject(router)
                    .environmentObject(tabSelection)
            }
        }
    }
}


