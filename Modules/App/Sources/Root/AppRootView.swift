import SwiftUI
import Shared
import DesignSystem

struct AppRootView: View {
    @Environment(TabSelection.self) private var tabSelection
    @Bindable var router: AppRouter
    let container: AppContainer

    @State private var launched = false
    @State private var showUnauthorizedAlert = false

    init(router: AppRouter, container: AppContainer) {
        self.router = router
        self.container = container
    }

    var body: some View {
        ZStack {
            if !launched {
                container.makeSplashView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }

            NavigationStack(path: $router.path) {
                rootView
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
            }
            .environment(router)
            .environment(tabSelection)
            .opacity(launched ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: launched)
        }
        .task {
            do {
                try await container.loadExploreOptions()
            } catch {
                print("Failed to load options: \(error)")
            }

            try? await Task.sleep(nanoseconds: UInt64(AppConstants.Duration.splash * 1_000_000_000))

            if TokenStorage.hasValidToken {
                AppState.shared.login()
                router.resetTo(.tabbar(selectedTab: .home))
            } else {
                router.resetTo(.onboarding)
            }

            withAnimation(.easeInOut(duration: AppConstants.Animation.default)) {
                launched = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveUnauthorized)) { _ in
            Task { await container.signOut() }
            AppState.shared.logout()
            showUnauthorizedAlert = true
        }
        .alert("로그인이 필요합니다", isPresented: $showUnauthorizedAlert) {
            Button("로그인하기") {
                router.resetTo(.login)
            }
        } message: {
            Text("세션이 만료되었습니다. 다시 로그인해주세요.")
        }
    }

    @ViewBuilder
    // swiftlint:disable:next cyclomatic_complexity
    private func makeView(for route: AppRoute) -> some View {
        switch route {
        case .onboarding:
            container.makeOnboardingView()
        case .signup:
            container.makeSignupView()
        case .login:
            container.makeLoginView()
        case .home:
            container.makeHomeView()
        case let .tabbar(selectedTab):
            container.makeTabView(selectedTab: selectedTab)
        case .profile:
            container.makeMypageView()
        case .explore:
            container.makeExploreView()
        case .brandDetail(let id):
            container.makeBrandDetailView(id: id)
        case .articleDetail(let id, let isPastArticle):
            container.makeArticleDetailView(id: id, isPastArticle: isPastArticle)
        case .editProfile:
            container.makeEditProfileView()
        case .recovery:
            container.makeRecoveryView()
        case .editNickname:
            container.makeEditNicknameView()
        case .editIndustry:
            container.makeEditIndustryView()
        case .editInterest:
            container.makeEditInterestView()
        case .accountManage:
            container.makeAccountManageView()
        case .updatePassword:
            container.makeChangePasswordView()
        case .updatePhoneNumber:
            container.makeChangePhoneNumberView()
        case .search:
            container.makeSearchView()
        case .serviceFeedback:
            container.makeFeedbackView()
        case .withdraw:
            container.makeWithdrawView()
        case .faq:
            container.makeFAQView()
        case .feedback:
            container.makeFeedbackView()
        case .termsMenu:
            container.makeTermsMenuView()
        case .editAlert:
            container.makeEditAlertView()
        }
    }

    @ViewBuilder
    private var rootView: some View {
        makeView(for: router.root)
    }

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        if case .articleDetail = route {
            makeView(for: route)
                .environment(router)
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        } else {
            makeView(for: route)
                .environment(router)
                .enableSwipeBack()
        }
    }
}
