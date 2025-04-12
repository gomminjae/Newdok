//
//  NewDokTabView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/13/25.
//

import SwiftUI
import Home
import DesignSystem

public struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(NewDokTab.home)
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
                tabItem(.home, normalAsset: DesignSystemAsset.lineHome, selectedAsset: DesignSystemAsset.fillHome, title: "홈")
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
                .font(DesignSystemFontFamily.SpoqaHanSansNeo.medium.swiftUIFont(size: 14))
                .foregroundColor(selectedTab == tab ? Color.primaryNormal : Color.gray)
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            selectedTab = tab
        }
    }

}

// MARK: - ✅ 탭 Enum (Home만 유지)
public enum NewDokTab: Int {
    case home
}


// MARK: - ✅ 4. 미리보기
struct NewDokTabView_Previews: PreviewProvider {
    static var previews: some View {
        NewDokTabView()
    }
}
