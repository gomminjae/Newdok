//
//  AppFlowCoordinatorView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/6/25.
//
import SwiftUI
import Launch
import Auth
import Signup
import Shared

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
            .onAppear {
                // 전역적으로 swipe back 활성화
                DispatchQueue.main.async {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        enableSwipeBackGlobally(in: rootViewController)
                    }
                }
            }
            .environmentObject(router)
            .environmentObject(tabSelection)
            .opacity(launched ? 1 : 0) // Splash 후 메인뷰 서서히 등장
            .animation(.easeInOut(duration: 0.3), value: launched)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    launched = true
                    print("AppRootView에서 router 인스턴스: \(Unmanaged.passUnretained(router).toOpaque())")
                    
                    // 토큰 존재 여부 확인 (로그인 여부)
                    if TokenStorage.hasValidToken {
                        // 토큰 있음 -> 메인 화면
                        router.resetTo(.tabbar(selectedTab: .home))
                    } else {
                        // 토큰 없음 -> 온보딩 (로그인하지 않은 사용자)
                        router.resetTo(.onboarding)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveUnauthorized)) { _ in
            // 401 에러 발생 시 팝업 표시
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
    private var rootView: some View {
        switch router.root {
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
    private func destinationView(for route: AppRoute) -> some View {
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
}

// MARK: - 전역 Swipe Back 설정
private func enableSwipeBackGlobally(in viewController: UIViewController) {
    // NavigationController 찾기
    func findNavigationController(in vc: UIViewController) -> UINavigationController? {
        if let nav = vc as? UINavigationController {
            return nav
        }
        for child in vc.children {
            if let nav = findNavigationController(in: child) {
                return nav
            }
        }
        return nil
    }
    
    if let navController = findNavigationController(in: viewController) {
        // 기본 swipe back 활성화
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.interactivePopGestureRecognizer?.delegate = nil
        
        // 커스텀 swipe back 처리
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(SwipeBackHandler.self, action: #selector(SwipeBackHandler.handleSwipeBack(_:)))
        viewController.view.addGestureRecognizer(panGesture)
    }
}

// MARK: - Swipe Back Handler
private class SwipeBackHandler: NSObject {
    @objc static func handleSwipeBack(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        // 오른쪽에서 왼쪽으로 스와이프 (뒤로가기)
        if translation.x > 50 && velocity.x > 0 {
            // AppRouter의 pop 메서드 호출
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .init("SwipeBack"), object: nil)
            }
        }
    }
}

