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
import Subscribe
import Bookmark
import Shared



public struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home
    @State private var previousTab: NewDokTab = .home
    
    @AppStorage("isGuest") private var isGuest: Bool = false
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection

    private let homeViewModel: HomeViewModel
    private let exploreViewModel: ExploreViewModel
    private let subscribeViewModel: SubscribeViewModel
    private let bookmarkViewModel: BookmarkViewModel
    private let mypageViewModel: MypageViewModel
    private let exploreIntent: ExploreIntent

    private let initialSelectedTab: NewDokTab?
    private let exploreDay: Int?
    private let exploreSelectedTab: Int?

    public init(
        homeViewModel: HomeViewModel,
        exploreViewModel: ExploreViewModel,
        subscribeViewModel: SubscribeViewModel,
        bookmarkViewModel: BookmarkViewModel,
        mypageViewModel: MypageViewModel,
        exploreIntent: ExploreIntent,
        selectedTab: NewDokTab? = nil,
        exploreDay: Int? = nil,
        exploreSelectedTab: Int? = nil
    ) {
        self.homeViewModel = homeViewModel
        self.exploreViewModel = exploreViewModel
        self.subscribeViewModel = subscribeViewModel
        self.bookmarkViewModel = bookmarkViewModel
        self.mypageViewModel = mypageViewModel
        self.exploreIntent = exploreIntent
        self.initialSelectedTab = selectedTab
        self.exploreDay = exploreDay
        self.exploreSelectedTab = exploreSelectedTab
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $tabSelection.selectedTab) {
                ExploreView(viewModel: exploreViewModel)
                    .environmentObject(exploreIntent)
                    .tag(NewDokTab.explore)
                SubscribeView(viewModel: subscribeViewModel)
                    .tag(NewDokTab.subscribe)
                HomeView(viewModel: homeViewModel)
                    .environmentObject(exploreIntent)
                    .tag(NewDokTab.home)
                BookmarkView(viewModel: bookmarkViewModel)
                    .tag(NewDokTab.bookmark)
                MypageView(viewModel: mypageViewModel)
                    .tag(NewDokTab.profile)
            }
            .edgesIgnoringSafeArea(.bottom)
            .onChange(of: tabSelection.selectedTab) { newTab in
                if isGuest && newTab == .profile {
                    tabSelection.selectedTab = .home
                    router.push(.login)
                }
            }
            
            NewDokTabBar(selectedTab: $tabSelection.selectedTab)
                .background(Color.white)
        }
        .environmentObject(tabSelection)
        .environmentObject(exploreViewModel)
        .onAppear {
            if let tab = initialSelectedTab {
                tabSelection.selectedTab = tab
            }
            if let day = exploreDay {
                exploreViewModel.day = [day]
            }
            if let selected = exploreSelectedTab {
                exploreViewModel.selectedTab = selected
            }
        }
        .background(Color.white)
    }
}



struct NewDokTabBar: View {
    @Binding var selectedTab: NewDokTab

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                tabItem(.explore, normalAsset: DesignSystemAsset.lineNewsletter, selectedAsset: DesignSystemAsset.fillNewsletter, title: "둘러보기")
                
                tabItem(.subscribe, normalAsset: DesignSystemAsset.lineMailbox, selectedAsset: DesignSystemAsset.fillMailbox, title: "구독관리")
                
                
                tabItem(.home, normalAsset: DesignSystemAsset.lineHome, selectedAsset: DesignSystemAsset.fillHome, title: "홈")
                
                tabItem(.bookmark, normalAsset: DesignSystemAsset.lineBookmark, selectedAsset: DesignSystemAsset.fillBookmark, title: "북마크함")
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


