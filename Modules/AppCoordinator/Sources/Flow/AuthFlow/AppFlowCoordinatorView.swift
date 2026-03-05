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

            withAnimation(.easeInOut(duration: AppConstants.Animation.default)) {
                launched = true

                // 토큰 존재 여부 확인 (로그인 여부)
                if TokenStorage.hasValidToken {
                    // 토큰 있음 -> 메인 화면 + 인증 상태 동기화
                    AppState.shared.login()
                    router.resetTo(.tabbar(selectedTab: .home))
                } else {
                    // 토큰 없음 -> 온보딩 (로그인하지 않은 사용자)
                    router.resetTo(.onboarding)
                }
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
        case .articleDetail(let id):
            coordinator.makeArticleDetail(id: id)
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
        // articleDetail은 WebView가 있어서 edge 범위만 사용
        if case .articleDetail = route {
            makeView(for: route)
                .environmentObject(router)
                .enableSwipeBack(edgeOnly: true)
        } else {
            makeView(for: route)
                .environmentObject(router)
                .enableSwipeBack()
        }
    }
}
