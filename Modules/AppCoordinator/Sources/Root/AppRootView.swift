import SwiftUI
import LaunchInterface
import AuthInterface
import Shared
import ExploreDomain
import DesignSystem

struct AppRootView: View {
    @Environment(TabSelection.self) private var tabSelection
    @Bindable var router: AppRouter
    let container: AppContainer
    let loadOptionsUseCase: LoadOptionsUseCase
    let signOut: @MainActor () async -> Void

    @State private var launched = false
    @State private var showUnauthorizedAlert = false

    init(
        router: AppRouter,
        container: AppContainer,
        loadOptionsUseCase: LoadOptionsUseCase,
        signOut: @escaping @MainActor () async -> Void
    ) {
        self.router = router
        self.container = container
        self.loadOptionsUseCase = loadOptionsUseCase
        self.signOut = signOut
    }

    var body: some View {
        ZStack {
            if !launched {
                container.launchFactory.makeSplashView()
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
                try await loadOptionsUseCase.execute()
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
            Task { await signOut() }
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
            container.authFactory.makeOnboardingView()
        case .signup:
            container.authFactory.makeSignupView()
        case .login:
            container.authFactory.makeLoginView()
        case .home:
            container.homeFactory.makeHomeView()
        case let .tabbar(selectedTab):
            container.makeTabView(selectedTab: selectedTab)
        case .profile:
            container.mypageFactory.makeMypageView()
        case .explore:
            container.exploreFactory.makeExploreView()
        case .brandDetail(let id):
            container.detailFactory.makeBrandDetailView(id: id)
        case .articleDetail(let id, let isPastArticle):
            container.detailFactory.makeArticleDetailView(id: id, isPastArticle: isPastArticle)
        case .editProfile:
            container.mypageFactory.makeEditProfileView()
        case .recovery:
            container.mypageFactory.makeRecoveryView()
        case .editNickname:
            container.mypageFactory.makeEditNicknameView()
        case .editIndustry:
            container.mypageFactory.makeEditIndustryView()
        case .editInterest:
            container.mypageFactory.makeEditInterestView()
        case .accountManage:
            container.mypageFactory.makeAccountManageView()
        case .updatePassword:
            container.mypageFactory.makeChangePasswordView()
        case .updatePhoneNumber:
            container.mypageFactory.makeChangePhoneNumberView()
        case .search:
            container.searchFactory.makeSearchView()
        case .serviceFeedback:
            container.mypageFactory.makeFeedbackView()
        case .withdraw:
            container.mypageFactory.makeWithdrawView()
        case .faq:
            container.mypageFactory.makeFAQView()
        case .feedback:
            container.mypageFactory.makeFeedbackView()
        case .termsMenu:
            container.mypageFactory.makeTermsMenuView()
        case .editAlert:
            container.mypageFactory.makeEditAlertView()
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
