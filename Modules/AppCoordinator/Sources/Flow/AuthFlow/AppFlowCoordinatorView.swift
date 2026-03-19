//
//  AppFlowCoordinatorView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/6/25.
//
import SwiftUI
import Launch
import Auth
import Shared
import Domain

struct AppRootView: View {
    @EnvironmentObject private var tabSelection: TabSelection
    @ObservedObject var router: AppRouter
    let exploreIntent: ExploreIntent

    private var coordinator: AppCoordinator {
        AppCoordinator(router: router, exploreIntent: exploreIntent)
    }

    @State private var launched = false
    @State private var showUnauthorizedAlert = false

    init(router: AppRouter, exploreIntent: ExploreIntent) {
        self.router = router
        self.exploreIntent = exploreIntent
    }
    
    var body: some View {
        ZStack {
            if !launched {
                SplashView()
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
            .opacity(launched ? 1 : 0) // Splash 후 메인뷰 서서히 등장
            .animation(.easeInOut(duration: 0.3), value: launched)
        }
        .task {
            // 옵션 리스트 로드
            do {
                guard let loadOptionsUseCase = AppDIContainer.shared.container.resolve(LoadOptionsUseCase.self) else {
                    fatalError("LoadOptionsUseCase is not registered in DI container")
                }
                try await loadOptionsUseCase.execute()
            } catch {
                print("Failed to load options: \(error)")
            }

            // Splash 화면 표시 후 초기 화면 결정
            try? await Task.sleep(nanoseconds: UInt64(AppConstants.Duration.splash * 1_000_000_000))

            // 토큰 존재 여부 확인 → splash 뒤에서 root를 먼저 결정
            if TokenStorage.hasValidToken {
                AppState.shared.login()
                router.resetTo(.tabbar(selectedTab: .home))
            } else {
                router.resetTo(.onboarding)
            }

            // root가 세팅된 후 splash를 걷음 → 온보딩 깜빡임 방지
            withAnimation(.easeInOut(duration: AppConstants.Animation.default)) {
                launched = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveUnauthorized)) { _ in
            // 401 에러 발생 시 로그인 상태 정리 + 팝업 표시
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
            coordinator.mekeProfileView()
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
            // 아티클 디테일: 하이라이트 드래그와 full-width pop 충돌 방지
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
