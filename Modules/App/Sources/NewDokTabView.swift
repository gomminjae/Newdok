//
//  NewDokTabView.swift
//  Newdok
//
//  Created by 권민재 on 3/1/25.
//

import SwiftUI
import Features
import DesignSystem

struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // ✅ Safe Area 적용
            TabView(selection: $selectedTab) {
                
                ExploreView()
                    .tag(NewDokTab.explore)
                
                HomeView()
                    .tag(NewDokTab.home)
                
                BookmarkView()
                    .tag(NewDokTab.bookmark)
                
                MypageView()
                    .tag(NewDokTab.mypage)
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
                tabItem(.explore, normalIcon: "Line Newsletter", selectedIcon: "Fill Newsletter", title: "둘러보기")
                tabItem(.subscription, normalIcon: "Line Mailbox", selectedIcon: "Fill Mailbox", title: "구독관리")
                tabItem(.home, normalIcon: "home", selectedIcon: "Fill Home", title: "홈")
                tabItem(.bookmark, normalIcon: "Line Bookmark", selectedIcon: "Fill Bookmark", title: "북마크함")
                tabItem(.mypage, normalIcon: "Line User", selectedIcon: "Fill User", title: "마이페이지")
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }

    private func tabItem(_ tab: NewDokTab, normalIcon: String, selectedIcon: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(selectedTab == tab ? selectedIcon : normalIcon)
                
                
            
            Text(title)
                .font(DesignSystemFontFamily.SpoqaHanSansNeo.medium.swiftUIFont(size: 14))
                .foregroundColor(selectedTab == tab ? Color.primaryNormal : Color.gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab
        }
    }
}


// MARK: - ✅ 3. 탭 Enum
enum NewDokTab: Int {
    case explore = 0
    case subscription
    case home
    case bookmark
    case mypage
}

// MARK: - ✅ 4. 미리보기
struct NewDokTabView_Previews: PreviewProvider {
    static var previews: some View {
        NewDokTabView()
    }
}
