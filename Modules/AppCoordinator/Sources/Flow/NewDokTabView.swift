//
//  NewDokTabView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/13/25.
//

import SwiftUI
import Home
import Mypage
import DesignSystem
import Explore


public enum NewDokTab: Int {
    case explore
    case home
    case profile
    
}

public struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home
    
    private let homeViewModel: HomeViewModel
    private let exploreViewModel: ExploreViewModel
    
    

    public init(
        homeViewModel: HomeViewModel,
        exploreViewModel: ExploreViewModel
    ) {
        self.homeViewModel = homeViewModel
        self.exploreViewModel = exploreViewModel
    }
    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                ExploreView(viewModel: exploreViewModel)
                    .tag(NewDokTab.explore)
                HomeView(viewModel: homeViewModel)
                    .tag(NewDokTab.home)
                MypageView()
                    .tag(NewDokTab.profile)
            
            }

            NewDokTabBar(selectedTab: $selectedTab)
                .background(Color.white)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct NewDokTabBar: View {
    @Binding var selectedTab: NewDokTab

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                tabItem(.explore, normalAsset: DesignSystemAsset.lineNewsletter, selectedAsset: DesignSystemAsset.fillNewsletter, title: "둘러보기")
                tabItem(.home, normalAsset: DesignSystemAsset.lineHome, selectedAsset: DesignSystemAsset.fillHome, title: "홈")
                tabItem(.profile, normalAsset: DesignSystemAsset.lineUser, selectedAsset: DesignSystemAsset.fillUser,title: "마이페이지")
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }

    private func tabItem(_ tab: NewDokTab, normalAsset: DesignSystemImages, selectedAsset: DesignSystemImages, title: String) -> some View {
        VStack(spacing: 4) {
            Image(asset: selectedTab == tab ? selectedAsset : normalAsset)
            Text(title)
                .font(.hanSansNeo(11,.medium))
                .foregroundColor(selectedTab == tab ? Color.primaryNormal : Color.gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab
        }
    }

}


