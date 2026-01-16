//
//  NewDokTabView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/13/25.
//

import SwiftUI
import UIKit
import Home
import Mypage
import DesignSystem
import Explore
import Subscribe
import Bookmark
import Shared

// MARK: - TabBar Appearance Setup
private func setupTabBarAppearance() {
    let selectedColor = UIColor(red: 40 / 255, green: 102 / 255, blue: 211 / 255, alpha: 1.0)
    let unselectedColor = UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 1.0)
    let tabBarAppearance = UITabBar.appearance()

    if #available(iOS 26.0, *) {
        // iOS 26+: 기본 Liquid Glass 유지하지만 색상은 지정
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.shadowColor = nil
        tabBarAppearance.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBarAppearance.scrollEdgeAppearance = appearance
        }
    } else {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { layoutAppearance in
            layoutAppearance.selected.iconColor = selectedColor
            layoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            layoutAppearance.normal.iconColor = unselectedColor
            layoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
        }

        tabBarAppearance.isTranslucent = false
        tabBarAppearance.standardAppearance = appearance
       
        if #available(iOS 15.0, *) {
            tabBarAppearance.scrollEdgeAppearance = appearance
        }
    }

    tabBarAppearance.tintColor = selectedColor
    tabBarAppearance.unselectedItemTintColor = unselectedColor
}

// MARK: - Constants for TabBar Background Control
private struct TabBarConstants {
    static let bottomOverlayHeight: CGFloat = 140
    static let tabBarHeight: CGFloat = 50
}

// MARK: - TabBar Background Modifier
struct TabBarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26+: 기본 Liquid Glass 유지
            content
        } else {
            // iOS 18-25: 하단 흰색 배경으로 TabBar 샘플링 색상 제어
            content
                .background(
                    Color.white
                        .ignoresSafeArea(.container, edges: .bottom)
                )
        }
    }
}

// MARK: - Scroll Content Background Modifier
struct ScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26+: 기본 유지
            content
        } else {
            // iOS 18-25: 스크롤 컨텐츠 배경을 흰색으로 고정
            content
                .background(Color.white)
        }
    }
}

// MARK: - Bottom White Overlay Modifier
struct BottomWhiteOverlayModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // iOS 26+: 기본 유지
            content
        } else {
            // iOS 18-25: 하단만 흰색 레이어 추가
            ZStack {
                content
                
                VStack {
                    Spacer()
                    Color.white
                        .frame(height: TabBarConstants.bottomOverlayHeight)
                        .ignoresSafeArea(.container, edges: .bottom)
                }
                .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - View Extensions for Easy Application
extension View {
    func tabBarBackground() -> some View {
        self.modifier(TabBarBackgroundModifier())
    }
    
    func scrollContentBackground() -> some View {
        self.modifier(ScrollContentBackgroundModifier())
    }
    
    func bottomWhiteOverlay() -> some View {
        self.modifier(BottomWhiteOverlayModifier())
    }
}

// MARK: - Tab Content Wrapper
struct TabContentView<Content: View>: View {
    let content: Content
    private let useBottomOverlay: Bool
    
    init(useBottomOverlay: Bool = false, @ViewBuilder content: () -> Content) {
        self.useBottomOverlay = useBottomOverlay
        self.content = content()
    }
    
    var body: some View {
        Group {
            if useBottomOverlay {
                content
                    .bottomWhiteOverlay()
            } else {
                content
                    .scrollContentBackground()
            }
        }
        .tabBarBackground()
    }
}



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
    
    @AppStorage("userId") private var userId: Int = 0

    public var body: some View {
        TabView(selection: $tabSelection.selectedTab) {
            TabContentView {
                ExploreView(viewModel: exploreViewModel)
                    .environmentObject(exploreIntent)
            }
            .tabItem {
                Group {
                    if tabSelection.selectedTab == .explore {
                        Image(asset: DesignSystemAsset.fillNewsletter)
                    } else {
                        Image(asset: DesignSystemAsset.lineNewsletter)
                            .renderingMode(.template)
                    }
                }
                Text("둘러보기")
            }
            .tag(NewDokTab.explore)
            
            TabContentView {
                SubscribeView(viewModel: subscribeViewModel)
            }
            .tabItem {
                Group {
                    if tabSelection.selectedTab == .subscribe {
                        Image(asset: DesignSystemAsset.fillMailbox)
                    } else {
                        Image(asset: DesignSystemAsset.lineMailbox)
                            .renderingMode(.template)
                    }
                }
                Text("구독관리")
            }
            .tag(NewDokTab.subscribe)
            
            TabContentView {
                HomeView(viewModel: homeViewModel)
                    .environmentObject(exploreIntent)
            }
            .tabItem {
                Group {
                    if tabSelection.selectedTab == .home {
                        Image(asset: DesignSystemAsset.fillHome)
                           
                    } else {
                        Image(asset: DesignSystemAsset.lineHome)
                            .renderingMode(.template)
                    }
                }
                Text("홈")
            }
            .tag(NewDokTab.home)
            
            TabContentView {
                BookmarkView(viewModel: bookmarkViewModel)
            }
            .tabItem {
                Group {
                    if tabSelection.selectedTab == .bookmark {
                        Image(asset: DesignSystemAsset.fillBookmark)
                          
                    } else {
                        Image(asset: DesignSystemAsset.lineBookmark)
                            .renderingMode(.template)
                    }
                }
                Text("북마크함")
            }
            .tag(NewDokTab.bookmark)
            
            TabContentView {
                MypageView(viewModel: mypageViewModel)
            }
            .tabItem {
                Group {
                    if tabSelection.selectedTab == .profile {
                        Image(asset: DesignSystemAsset.fillUser)
                          
                    } else {
                        Image(asset: DesignSystemAsset.lineUser)
                            .renderingMode(.template)
                    }
                }
                Text("마이페이지")
            }
            .tag(NewDokTab.profile)
        }
        .id(userId == 0 ? "guest" : "user_\(userId)")
        .onChange(of: tabSelection.selectedTab) { _, newTab in
            if isGuest && newTab == .profile {
                tabSelection.selectedTab = .home
                router.push(.login)
            }
            switch newTab {
            case .explore:
                router.root = .tabbar(selectedTab: .explore)
            case .home:
                router.root = .tabbar(selectedTab: .home)
                
            case .subscribe:
                router.root = .tabbar(selectedTab: .subscribe)
               
            case .bookmark:
                router.root = .tabbar(selectedTab: .bookmark)
              
            case .profile: 
                router.root = .tabbar(selectedTab: .profile)
                
            }
        }
        .modifier(TabBarBackgroundModifier())
        .accentColor(Color.primaryNormal)
        .environmentObject(tabSelection)
        .environmentObject(exploreViewModel)
        .onAppear {
            // 다크모드 방지 설정
            setupTabBarAppearance()
        }
    }
}



struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

struct NewDokTabBar: View {
    @Binding var selectedTab: NewDokTab
    @State private var tabAnimations: [NewDokTab: Bool] = [:]

    init(selectedTab: Binding<NewDokTab>) {
        self._selectedTab = selectedTab
        self._tabAnimations = State(initialValue: Dictionary(uniqueKeysWithValues: NewDokTab.allCases.map { ($0, false) }))
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 0) {
                tabItem(.explore, normalAsset: DesignSystemAsset.lineNewsletter, selectedAsset: DesignSystemAsset.fillNewsletter, title: "둘러보기")
                
                tabItem(.subscribe, normalAsset: DesignSystemAsset.lineMailbox, selectedAsset: DesignSystemAsset.fillMailbox, title: "구독관리")
                
                tabItem(.home, normalAsset: DesignSystemAsset.lineHome, selectedAsset: DesignSystemAsset.fillHome, title: "홈")
                
                tabItem(.bookmark, normalAsset: DesignSystemAsset.lineBookmark, selectedAsset: DesignSystemAsset.fillBookmark, title: "북마크함")
                
                tabItem(.profile, normalAsset: DesignSystemAsset.lineUser, selectedAsset: DesignSystemAsset.fillUser, title: "마이페이지")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(height: 50)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .background(Color.clear)
        .onChange(of: selectedTab) { _, newTab in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tabAnimations[newTab] = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    tabAnimations[newTab] = false
                }
            }
        }
    }

    private func tabItem(_ tab: NewDokTab, normalAsset: DesignSystemImages, selectedAsset: DesignSystemImages, title: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Image(asset: normalAsset)
                    .renderingMode(.template)
                    .foregroundColor(Color.gray.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .scaleEffect(selectedTab == tab ? 0.8 : 1.0)
                    .opacity(selectedTab == tab ? 0 : 1)
                
                Image(asset: selectedAsset)
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                    .scaleEffect(selectedTab == tab ? (tabAnimations[tab] == true ? 1.2 : 1.0) : 0.8)
                    .opacity(selectedTab == tab ? 1 : 0)
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            
            Text(title)
                .font(.hanSansNeo(10, selectedTab == tab ? .bold : .medium))
                .foregroundColor(selectedTab == tab ? Color.primaryNormal : Color.gray.opacity(0.7))
                .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedTab != tab {
                selectedTab = tab
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
}

