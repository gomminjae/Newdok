import Foundation
import Swinject
import Moya
import Core
import Domain
import AppCoordinator
import Auth
import AuthInterface
import AuthDomain
import AuthData
import Home
import HomeInterface
import HomeDomain
import HomeData
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
    private static var container: Container { AppDIContainer.shared.container }

    static func makeAuthFactory() -> AuthViewFactory {
        let authRepo = AuthRepositoryImpl(
            provider: container.resolve(MoyaProvider<UserAPI>.self)!
        )
        return AuthViewFactoryImpl(
            signupViewModelProvider: {
                let loginUseCase = LoginUseCaseImpl(authRepository: authRepo)
                let signupUseCase = SignupUseCaseImpl(authRepository: authRepo, loginUseCase: loginUseCase)
                return SignupViewModel(authRepository: authRepo, signupUseCase: signupUseCase)
            },
            loginViewModelProvider: {
                let loginUseCase = LoginUseCaseImpl(authRepository: authRepo)
                return LoginViewModel(loginUseCase: loginUseCase)
            }
        )
    }

    static func makeHomeFactory() -> HomeViewFactory {
        return HomeViewFactoryImpl(viewModelProvider: {
            let articleRepo = HomeArticleRepositoryImpl(
                provider: container.resolve(MoyaProvider<ArticleAPI>.self)!
            )
            let newsletterRepo = HomeNewsletterRepositoryImpl(
                provider: container.resolve(MoyaProvider<NewsletterAPI>.self)!
            )
            let fetchUseCase = FetchHomeDataUseCaseImpl(newsletterRepo: newsletterRepo, articleRepo: articleRepo)
            let businessUseCase = DefaultHomeBusinessUseCase(fetchUseCase: fetchUseCase)
            return HomeViewModel(useCase: businessUseCase)
        })
    }

    static func makeExploreFactory() -> ExploreViewFactory {
        return ExploreViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(NewsletterUseCase.self)!
            return ExploreViewModel(useCase: useCase)
        })
    }

    static func makeSubscribeFactory() -> SubscribeViewFactory {
        return SubscribeViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(NewsletterUseCase.self)!
            return SubscribeViewModel(useCase: useCase)
        })
    }

    static func makeBookmarkFactory() -> BookmarkViewFactory {
        return BookmarkViewFactoryImpl(viewModelProvider: {
            let useCase = container.resolve(ArticleUseCase.self)!
            return BookmarkViewModel(useCase: useCase)
        })
    }

    static func makeDetailFactory() -> DetailViewFactory {
        return DetailViewFactoryImpl(
            brandDetailViewModelProvider: { id in
                let useCase = container.resolve(NewsletterUseCase.self)!
                return BrandDetailViewModel(id: id, useCase: useCase)
            },
            articleDetailViewModelProvider: { id in
                let articleUseCase = container.resolve(ArticleUseCase.self)!
                let detailUseCase = ArticleDetailUseCaseImpl(articleUseCase: articleUseCase)
                return ArticleDetailViewModel(id: id, articleDetailUseCase: detailUseCase)
            }
        )
    }

    static func makeSearchFactory() -> SearchViewFactory {
        return SearchViewFactoryImpl(viewModelProvider: {
            let repo = container.resolve(SearchRepository.self)!
            let useCase = SearchUseCaseImpl(searchRepository: repo)
            return SearchViewModel(useCase: useCase)
        })
    }

    static func makeMypageFactory() -> MypageViewFactory {
        return MypageViewFactoryImpl(
            mypageViewModelProvider: {
                let userUseCase = container.resolve(UserUseCase.self)!
                let profileUseCase = ProfileUseCaseImpl(userUseCase: userUseCase)
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
