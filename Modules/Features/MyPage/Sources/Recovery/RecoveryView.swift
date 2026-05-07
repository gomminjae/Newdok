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

public struct RecoveryView: View {
    @State private var selectedTab: Int = 0
  
    @State private var viewModel: RecoveryViewModel

    @Environment(AppRouter.self) private var router

    public init(viewModel: RecoveryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            ZStack {
                VStack(spacing: 0) {
                    tabSwitcher
                    if selectedTab == 0 {
                        FindIdPagerView(viewModel: viewModel)
                    } else {
                        PasswordRecoveryPagerView(viewModel: viewModel)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity,           // 가로 꽉 채우기
                      maxHeight: .infinity,          // 세로도 꽉 채우기
                      alignment: .topLeading)
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
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
        .ignoresSafeArea(.keyboard)
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: {}
        )
    }
    private var tabSwitcher: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(title: "아이디 찾기", index: 0)
                tabButton(title: "비밀번호 찾기", index: 1)
            }
           
            GeometryReader { geometry in
                let width = geometry.size.width / 2
                Rectangle()
                    .fill(Color.captionStrong)
                    .frame(width: width, height: 2)
                    .offset(x: selectedTab == 0 ? 0 : width)
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
            }
            .frame(height: 2)
        }
        .padding(.top, 16)
    }
    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(selectedTab == index ? Color.captionStrong : Color.captionAlternative)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}
