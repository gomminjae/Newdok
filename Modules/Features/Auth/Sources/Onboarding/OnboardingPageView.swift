//
//  OnboardingPageView.swift
//  Signup
//
//  Created by 권민재 on 4/9/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import SwiftUI
import DesignSystem

struct OnboardingPageView: View {
    let title: String
    let subtitle: String
    let imageName: DesignSystemImages
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(subtitle)
                .font(.hanSansNeo(22, .bold))
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .padding(.top, 12)
            
            Image(asset: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)
                .padding(.top, 80)
            
            Spacer()
        }
        .padding(.top, 64)
    }
}
