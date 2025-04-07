
import SwiftUI
import AppCoordinator
import DesignSystem




@main
struct AApp: App {
    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
    
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorEntry.makeAFlow()
        }
    }
}


