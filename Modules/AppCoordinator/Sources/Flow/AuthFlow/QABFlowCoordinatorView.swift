//
//  QABFlowCoordinatorView.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/6/25.
//
import SwiftUI
import Launch
import Auth
import Signup
import Shared

struct QABRootView: View {
    @EnvironmentObject private var tabSelection: TabSelection
    @ObservedObject var router: AppRouter
    let exploreIntent: ExploreIntent

    private var coordinator: AppCoordinator {
        AppCoordinator(router: router, exploreIntent: exploreIntent)
    }
    
    @State private var launched = false
    
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
                Group {
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
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
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
                    print("QABRootViewView에서 router 인스턴스: \(Unmanaged.passUnretained(router).toOpaque())")
                }
            }
        }
    }
}

