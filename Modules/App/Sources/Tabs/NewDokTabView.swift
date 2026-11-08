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
    let container: AppContainer
    @Bindable var appRouter: AppRouter

    @AppStorage("userId") private var userId: Int = 0

    var body: some View {
        TabView(selection: $appRouter.selectedTab) {
            Tab(value: NewDokTab.explore) {
                TabContentView {
                    ExploreStack(container: container, appRouter: appRouter)
                        .analyticsVisibility(appRouter.selectedTab == .explore)
                }
            } label: {
                Image(asset: DesignSystemAsset.lineNewsletter)
                    .renderingMode(.template)
                Text("둘러보기")
            }
            Tab(value: NewDokTab.subscribe) {
                TabContentView {
                    SubscribeStack(container: container, appRouter: appRouter)
                        .analyticsVisibility(appRouter.selectedTab == .subscribe)
                }
            } label: {
                Image(asset: DesignSystemAsset.lineMailbox)
                    .renderingMode(.template)
                Text("구독관리")
            }
            Tab(value: NewDokTab.home) {
                TabContentView {
                    HomeStack(container: container, appRouter: appRouter)
                        .analyticsVisibility(appRouter.selectedTab == .home)
                }
            } label: {
                Image(asset: DesignSystemAsset.lineHome)
                    .renderingMode(.template)
                Text("홈")
            }
            Tab(value: NewDokTab.bookmark) {
                TabContentView {
                    BookmarkStack(container: container, appRouter: appRouter)
                        .analyticsVisibility(appRouter.selectedTab == .bookmark)
                }
            } label: {
                Image(asset: DesignSystemAsset.lineBookmark)
                    .renderingMode(.template)
                Text("북마크함")
            }
            Tab(value: NewDokTab.profile) {
                TabContentView {
                    MyPageStack(container: container, appRouter: appRouter)
                        .analyticsVisibility(appRouter.selectedTab == .profile)
                }
            } label: {
                Image(asset: DesignSystemAsset.lineUser)
                    .renderingMode(.template)
                Text("마이페이지")
            }
            if #available(iOS 27.0, *) {
                Tab(value: NewDokTab.search, role: .prominent) {
                    TabContentView {
                        SearchStack(container: container, appRouter: appRouter)
                            .analyticsVisibility(appRouter.selectedTab == .search)
                    }
                } label: {
                    Image(asset: DesignSystemAsset.lineSearch)
                        .renderingMode(.template)
                    Text("검색")
                }
            }
        }
        .id(userId == 0 ? "guest" : "user_\(userId)")
        .onChange(of: appRouter.selectedTab) { _, newTab in
            if AppState.shared.authState == .guest && newTab == .profile {
                appRouter.navigate(to: .tab(.home))
                appRouter.navigate(to: .auth(.login))
            }
        }
        .navigationBarHidden(true)
        .accentColor(Color.primaryNormal)
        .onAppear {
            setupTabBarAppearance()
        }
    }
}
