import SwiftUI
import LaunchInterface
import AuthInterface
import Shared
import ExploreDomain
import DesignSystem

struct AppRootView: View {
    @EnvironmentObject private var tabSelection: TabSelection
    @ObservedObject var router: AppRouter
    let exploreIntent: ExploreIntent
    let coordinator: AppCoordinator

    @State private var launched = false
    @State private var showUnauthorizedAlert = false

    init(router: AppRouter, exploreIntent: ExploreIntent, coordinator: AppCoordinator) {
        self.router = router
        self.exploreIntent = exploreIntent
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if !launched {
                coordinator.launchFactory.makeSplashView()
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
            .environmentObject(router)
            .environmentObject(tabSelection)
            .opacity(launched ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: launched)
        }
        .task {
            do {
                guard let loadOptionsUseCase = AppDIContainer.shared.container.resolve(LoadOptionsUseCase.self) else {
                    fatalError("LoadOptionsUseCase is not registered in DI container")
                }
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
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            UserDefaults.standard.set(false, forKey: "isGuest")
            UserDefaults.standard.removeObject(forKey: "nickname")
            UserDefaults.standard.removeObject(forKey: "email")
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
            coordinator.makeOnboardingView()
        case .signup:
            coordinator.makeSignupView()
        case .login:
            coordinator.makeLoginView()
        case .home:
            coordinator.makeHomeView()
        case let .tabbar(selectedTab, exploreDay, exploreSelectedTab):
            coordinator.makeTabView(selectedTab: selectedTab, exploreDay: exploreDay, exploreSelectedTab: exploreSelectedTab)
        case .profile:
            coordinator.makeProfileView()
        case .explore:
            coordinator.makeExploreView()
        case .brandDetail(let id):
            coordinator.makeBrandDetail(id: id)
        case .articleDetail(let id, let isPastArticle):
            coordinator.makeArticleDetail(id: id, isPastArticle: isPastArticle)
        case .editProfile:
            coordinator.makeEditProfileView()
        case .recovery:
            coordinator.makeRecoveryView()
        case .editNickname:
            coordinator.makeEditNicknameView()
        case .editIndustry:
            coordinator.makeEditIndustryView()
        case .editInterest:
            coordinator.makeEditInterestView()
        case .accountManage:
            coordinator.makeAccountManageView()
        case .updatePassword:
            coordinator.makeChangePasswordView()
        case .updatePhoneNumber:
            coordinator.makeChangePhoneNumberView()
        case .search:
            coordinator.makeSearchView()
        case .serviceFeedback:
            coordinator.makeServiceFeedbackView()
        case .withdraw:
            coordinator.makeWithdrawView()
        case .faq:
            coordinator.makeFAQView()
        case .feedback:
            coordinator.makeFeedbackView()
        case .termsMenu:
            coordinator.makeTermsMenuView()
        case .editAlert:
            coordinator.makeEditAlert()
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
                .environmentObject(router)
                .enableSwipeBack()
                .swipeBackFullWidthDisabled(true)
        } else {
            makeView(for: route)
                .environmentObject(router)
                .enableSwipeBack()
        }
    }
}
