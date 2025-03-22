//
//  ContentView.swift
//  Newdok
//
//  Created by 권민재 on 2/14/25.
//
import SwiftUI
import Features

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

#Preview {
    ContentView()
}
