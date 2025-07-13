
import SwiftUI
import AppCoordinator
import DesignSystem
import Shared




@main
struct AApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var exploreIntent = ExploreIntent()

    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
    
    
    var body: some Scene {
        WindowGroup {
            OverlayRootView {
                AppCoordinatorEntry.makeAFlow(router: router, exploreIntent: exploreIntent)
                    .environmentObject(router)
                    .environmentObject(tabSelection)
            }
        }
    }
}


