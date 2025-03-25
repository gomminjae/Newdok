


import SwiftUI
import Signup
import Auth
import Launch
import DesignSystem


@main

struct BApp: App {
    
    @State private var isLaunch: Bool = true
    
    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
