//
//  ContentView.swift
//  B
//
//  Created by 권민재 on 3/24/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import Launch
import Signup
import Auth

struct ContentView: View {
    
    @State private var isLaunch: Bool = true
    
    
    var body: some View {
        
        if isLaunch {
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.linear) {
                            self.isLaunch = false
                        }
                    }
                }
            
        } else {
            OnboardingView()
            
        }
    }
}
