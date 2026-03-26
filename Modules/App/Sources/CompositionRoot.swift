import Foundation
import Swinject
import Domain
import AppCoordinator
import Auth
import AuthInterface
import Home
import HomeInterface
import Explore
import ExploreInterface
import Subscribe
import SubscribeInterface
import Bookmark
import BookmarkInterface
import Detail
import DetailInterface
import Search
import SearchInterface
import Mypage
import MypageInterface
import Launch
import LaunchInterface

@MainActor
enum CompositionRoot {
    static func makeAuthFactory() -> AuthViewFactory {
        let container = AppDIContainer.shared.container
        return AuthViewFactoryImpl(
            signupViewModelProvider: {
                let userUseCase = container.resolve(UserUseCase.self)!
                let signupUseCase = container.resolve(SignupUseCase.self)!
                return SignupViewModel(userUseCase: userUseCase, signupUseCase: signupUseCase)
            },
            loginViewModelProvider: {
                let loginUseCase = container.resolve(LoginUseCase.self)!
                return LoginViewModel(loginUseCase: loginUseCase)
            }
        )
    }

    static func makeHomeFactory() -> HomeViewFactory {
        let container = AppDIContainer.shared.container
        return HomeViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(HomeBusinessUseCase.self)!
            return HomeViewModel(useCase: useCase)
        })
    }

    static func makeExploreFactory() -> ExploreViewFactory {
        let container = AppDIContainer.shared.container
        return ExploreViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(NewsletterUseCase.self)!
            return ExploreViewModel(useCase: useCase)
        })
    }

    static func makeSubscribeFactory() -> SubscribeViewFactory {
        let container = AppDIContainer.shared.container
        return SubscribeViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(NewsletterUseCase.self)!
            return SubscribeViewModel(useCase: useCase)
        })
    }

    static func makeBookmarkFactory() -> BookmarkViewFactory {
        let container = AppDIContainer.shared.container
        return BookmarkViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(ArticleUseCase.self)!
            return BookmarkViewModel(useCase: useCase)
        })
    }

    static func makeDetailFactory() -> DetailViewFactory {
        let container = AppDIContainer.shared.container
        return DetailViewFactoryImpl(
            brandDetailViewModelProvider: { id in
                let useCase = container.resolve(NewsletterUseCase.self)!
                return BrandDetailViewModel(id: id, useCase: useCase)
            },
            articleDetailViewModelProvider: { id in
                let useCase = container.resolve(ArticleDetailUseCase.self)!
                return ArticleDetailViewModel(id: id, articleDetailUseCase: useCase)
            }
        )
    }

    static func makeSearchFactory() -> SearchViewFactory {
        let container = AppDIContainer.shared.container
        return SearchViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(SearchUseCase.self)!
            return SearchViewModel(useCase: useCase)
        })
    }

    static func makeMypageFactory() -> MypageViewFactory {
        let container = AppDIContainer.shared.container
        return MypageViewFactoryImpl(
            mypageViewModelProvider: {
                let userUseCase = container.resolve(UserUseCase.self)!
                let profileUseCase = container.resolve(ProfileUseCase.self)!
                return MypageViewModel(useCase: userUseCase, profileUseCase: profileUseCase)
            },
            recoveryViewModelProvider: {
                let useCase = container.resolve(UserUseCase.self)!
                return RecoveryViewModel(useCase: useCase)
            },
            withdrawViewModelProvider: {
                let userUseCase = container.resolve(UserUseCase.self)!
                let newsletterUseCase = container.resolve(NewsletterUseCase.self)!
                let articleUseCase = container.resolve(ArticleUseCase.self)!
                return WithdrawViewModel(
                    userUseCase: userUseCase,
                    newsletterUseCase: newsletterUseCase,
                    articleUseCase: articleUseCase
                )
            }
        )
    }

    static func makeLaunchFactory() -> LaunchViewFactory {
        return LaunchViewFactoryImpl()
    }
}
