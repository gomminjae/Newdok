//
//  NewdokApp.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//

import SwiftUI

@main
struct NewdokApp: App {
    
    @StateObject private var loginState = LoginState()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginState)
        }
    }
}
