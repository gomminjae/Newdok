import SwiftUI
import UIKit
import DesignSystem
import Shared

@MainActor
private func setupTabBarAppearance() {
    let selectedColor = UIColor(red: 40 / 255, green: 102 / 255, blue: 211 / 255, alpha: 1.0)
    let unselectedColor = UIColor(red: 150 / 255, green: 150 / 255, blue: 150 / 255, alpha: 1.0)
    let tabBarAppearance = UITabBar.appearance()

    let appearance = UITabBarAppearance()

    if #available(iOS 26.0, *) {
        appearance.configureWithDefaultBackground()
        appearance.shadowColor = nil
    } else {
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = nil
        tabBarAppearance.isTranslucent = false
    }

    [appearance.stackedLayoutAppearance,
     appearance.inlineLayoutAppearance,
     appearance.compactInlineLayoutAppearance].forEach { layoutAppearance in
        layoutAppearance.selected.iconColor = selectedColor
        layoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        layoutAppearance.normal.iconColor = unselectedColor
        layoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]
    }

    tabBarAppearance.standardAppearance = appearance

    if #available(iOS 15.0, *) {
        tabBarAppearance.scrollEdgeAppearance = appearance
    }

    tabBarAppearance.tintColor = selectedColor
    tabBarAppearance.unselectedItemTintColor = unselectedColor
}

private struct TabBarConstants {
    static let bottomOverlayHeight: CGFloat = 140
    static let tabBarHeight: CGFloat = 50
}

struct TabBarBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .background(Color.white)
        }
    }
}

struct ScrollContentBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            content
                .background(Color.white)
        }
    }
}

struct BottomWhiteOverlayModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
        } else {
            ZStack {
                content

                VStack {
                    Spacer()
                    Color.white
                        .frame(height: TabBarConstants.bottomOverlayHeight)
                }
                .allowsHitTesting(false)
            }
        }
    }
}

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

struct NewDokTabView: View {
    @State private var selectedTab: NewDokTab = .home
    @State private var previousTab: NewDokTab = .home

    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection
    @Environment(AppState.self) private var appState

    private var isGuest: Bool { appState.authState == .guest }

    private let container: AppContainer
    private let initialSelectedTab: NewDokTab?

    init(container: AppContainer, selectedTab: NewDokTab? = nil) {
        self.container = container
        self.initialSelectedTab = selectedTab
    }

    @AppStorage("userId") private var userId: Int = 0
    @State private var didApplyInitialTab = false

    var body: some View {
        @Bindable var tabSelection = tabSelection
        TabView(selection: $tabSelection.selectedTab) {
            TabContentView {
                container.makeExploreView()
            }
            .tabItem {
                Image(asset: DesignSystemAsset.lineNewsletter)
                    .renderingMode(.template)
                Text("둘러보기")
            }
            .tag(NewDokTab.explore)

            TabContentView {
                container.makeSubscribeView()
            }
            .tabItem {
                Image(asset: DesignSystemAsset.lineMailbox)
                    .renderingMode(.template)
                Text("구독관리")
            }
            .tag(NewDokTab.subscribe)

            TabContentView {
                container.makeHomeView()
            }
            .tabItem {
                Image(asset: DesignSystemAsset.lineHome)
                    .renderingMode(.template)
                Text("홈")
            }
            .tag(NewDokTab.home)

            TabContentView {
                container.makeBookmarkView()
            }
            .tabItem {
                Image(asset: DesignSystemAsset.lineBookmark)
                    .renderingMode(.template)
                Text("북마크함")
            }
            .tag(NewDokTab.bookmark)

            TabContentView {
                container.makeMypageView()
            }
            .tabItem {
                Image(asset: DesignSystemAsset.lineUser)
                    .renderingMode(.template)
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
        }
        .navigationBarHidden(true)
        .accentColor(Color.primaryNormal)
        .environment(tabSelection)
        .onAppear {
            setupTabBarAppearance()
            if !didApplyInitialTab, let tab = initialSelectedTab {
                tabSelection.selectedTab = tab
                didApplyInitialTab = true
            }
        }
    }
}
