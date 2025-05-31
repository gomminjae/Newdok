//
//  RecoveryView.swift
//  Recovery
//
//  Created by 권민재 on 5/31/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Shared
import DesignSystem



struct RecoveryView: View {
    @State private var selectedTab: Int = 0
    @State private var currentPage: Int = 0
    var body: some View {
        VStack {
            ZStack {
                VStack(spacing: 0) {
                    tabSwitcher
                    if selectedTab == 0 {
                        FindIdPagerView()
                    } else {
                        FindIdPagerView()
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("계정찾기")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
    }
    private var tabSwitcher: some View {
        VStack(spacing: 0) {
            
            
            
            HStack(spacing: 0) {
                tabButton(title: "아이디 찾기", index: 0)
                tabButton(title: "비밀번호 찾기", index: 1)
            }
            .padding(.top, 16)
            
            
            GeometryReader { geometry in
                let width = geometry.size.width / 2
                Rectangle()
                    .fill(Color(hex: "#363636"))
                    .frame(width: width, height: 2)
                    .offset(x: selectedTab == 0 ? 0 : width)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .frame(height: 2)
        }
    }
    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(selectedTab == index ? Color(hex: "#363636") : Color(hex: "#767676"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
    
    
}

#Preview {
    RecoveryView()
}
