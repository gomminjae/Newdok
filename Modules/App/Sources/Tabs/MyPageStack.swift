import SwiftUI
import DesignSystem

struct MyPageStack: View {
    let container: AppContainer
    let appRouter: AppRouter

    var body: some View {
        @Bindable var appRouter = appRouter
        NavigationStack(path: $appRouter.myPagePath) {
            container.makeMypageView(
                onEditProfile: { appRouter.myPagePath.append(.editProfile) },
                onEditAlert: { appRouter.myPagePath.append(.editAlert) },
                onFAQ: { appRouter.myPagePath.append(.faq) },
                onFeedback: { appRouter.myPagePath.append(.feedback) },
                onTermsMenu: { appRouter.myPagePath.append(.termsMenu) },
                onLoggedOut: { appRouter.handleLogout(presenting: .login) },
                onWithdraw: { appRouter.myPagePath.append(.withdraw) }
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
                onBack: { _ = appRouter.myPagePath.popLast() },
                onEditNickname: { appRouter.myPagePath.append(.editNickname) },
                onEditIndustry: { appRouter.myPagePath.append(.editIndustry) },
                onEditInterest: { appRouter.myPagePath.append(.editInterest) }
            )
        case .editNickname:
            container.makeEditNicknameView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .editIndustry:
            container.makeEditIndustryView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .editInterest:
            container.makeEditInterestView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .withdraw:
            container.makeWithdrawView(
                onBack: { _ = appRouter.myPagePath.popLast() },
                onWithdrawn: { appRouter.handleLogout(presenting: .onboarding) }
            )
        case .editAlert:
            container.makeEditAlertView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .faq:
            container.makeFAQView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .feedback:
            container.makeFeedbackView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .termsMenu:
            container.makeTermsMenuView(onBack: { _ = appRouter.myPagePath.popLast() })
        case .version:
            container.makeVersionView(onBack: { _ = appRouter.myPagePath.popLast() })
        }
    }
}
