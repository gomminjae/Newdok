import SwiftUI
import DesignSystem

struct MyPageStack: View {
    let container: AppContainer
    let coordinator: AppCoordinator

    var body: some View {
        @Bindable var router = coordinator.mypageRouter
        NavigationStack(path: $router.path) {
            container.makeMypageView(
                onEditProfile: { coordinator.mypageRouter.push(.editProfile) },
                onAccountManage: { coordinator.mypageRouter.push(.accountManage) },
                onEditAlert: { coordinator.mypageRouter.push(.editAlert) },
                onFAQ: { coordinator.mypageRouter.push(.faq) },
                onFeedback: { coordinator.mypageRouter.push(.feedback) },
                onTermsMenu: { coordinator.mypageRouter.push(.termsMenu) }
            )
            .navigationDestination(for: MyPageRoute.self) { route in
                destination(route)
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: MyPageRoute) -> some View {
        switch route {
        case .editProfile:
            container.makeEditProfileView(
                onBack: { coordinator.mypageRouter.pop() },
                onEditNickname: { coordinator.mypageRouter.push(.editNickname) },
                onEditIndustry: { coordinator.mypageRouter.push(.editIndustry) },
                onEditInterest: { coordinator.mypageRouter.push(.editInterest) }
            )
        case .editNickname:
            container.makeEditNicknameView(onBack: { coordinator.mypageRouter.pop() })
        case .editIndustry:
            container.makeEditIndustryView(onBack: { coordinator.mypageRouter.pop() })
        case .editInterest:
            container.makeEditInterestView(onBack: { coordinator.mypageRouter.pop() })
        case .accountManage:
            container.makeAccountManageView(
                onBack: { coordinator.mypageRouter.pop() },
                onWithdraw: { coordinator.mypageRouter.push(.withdraw) },
                onLoggedOut: { coordinator.logout(to: .login) }
            )
        case .withdraw:
            container.makeWithdrawView(
                onBack: { coordinator.mypageRouter.pop() },
                onWithdrawn: { coordinator.logout(to: .onboarding) }
            )
        case .editAlert:
            container.makeEditAlertView(onBack: { coordinator.mypageRouter.pop() })
        case .faq:
            container.makeFAQView(onBack: { coordinator.mypageRouter.pop() })
        case .feedback:
            container.makeFeedbackView(onBack: { coordinator.mypageRouter.pop() })
        case .termsMenu:
            container.makeTermsMenuView(onBack: { coordinator.mypageRouter.pop() })
        case .version:
            container.makeVersionView(onBack: { coordinator.mypageRouter.pop() })
        }
    }
}
