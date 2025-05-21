//
//  LoadingView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/22/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var isLoading = false
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<5, id: \.self) { index in
                ZStack {
                    // 배경 원
                    Circle()
                        .stroke(Color(.white), lineWidth: 5)
                        .frame(width: 50, height: 50)
                    
                    // 진행 중인 원 (그라디언트 효과)
                    Circle()
                        .trim(from: 0, to: 0.5)
                        .stroke(LinearGradient(gradient: Gradient(colors: [Color(hex:"#2866D3"), Color.white]), startPoint: .top, endPoint: .top), lineWidth: 5)
                        .frame(width: 50, height: 50)
                        .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.2), // 각 원의 시작 시점을 다르게 설정
                            value: isLoading
                        )
                        .onAppear {
                            self.isLoading = true
                        }
                }
            }
        }
        .background(Color(hex: "#F5F5F7"))
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
