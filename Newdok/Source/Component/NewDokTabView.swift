//
//  NewDokTabView.swift
//  Newdok
//
//  Created by 권민재 on 3/1/25.
//

import SwiftUI

struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // ✅ Safe Area 적용
            TabView(selection: $selectedTab) {
                
                Text("구독관리 화면")
                    .tag(NewDokTab.subscription)
                
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


// MARK: - ✅ 2. NewDokTabBar (하단 탭바)
struct NewDokTabBar: View {
    @Binding var selectedTab: NewDokTab

    var body: some View {
        VStack(spacing: 0) {
            Divider() // 상단 구분선
            
            HStack {
                tabItem(.explore, icon: "around", title: "둘러보기")
                tabItem(.subscription, icon: "mailbox", title: "구독관리")
                tabItem(.home, icon: "home", title: "홈") // 선택된 탭
                tabItem(.bookmark, icon: "bookmark", title: "북마크함")
                tabItem(.mypage, icon: "person", title: "마이페이지")
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            
        }
        .background(Color.white)
    }

    private func tabItem(_ tab: NewDokTab, icon: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(icon)
                .font(.system(size: 22))
                .foregroundColor(selectedTab == tab ? Color.primaryNormal : Color.gray)

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
