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
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        VStack {
            Spacer(minLength: 64)
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
            
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .frame(width: currentPage == index ? 32 : 32, height: 6)
                        .foregroundColor(currentPage == index ? .primaryNormal : Color.blue.opacity(0.2))
                }
            }
            .padding(.top, 34)
            
            Image(asset: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 320, height: 320)
                .padding()
            
            
            
            Spacer()
        }
        .padding()
    }
}
