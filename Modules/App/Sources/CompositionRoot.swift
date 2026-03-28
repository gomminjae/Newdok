import Foundation
import Swinject
import Core
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
import ExploreDomain
import ExploreData
import Subscribe
import SubscribeInterface
import SubscribeDomain
import SubscribeData
import Bookmark
import BookmarkInterface
import BookmarkDomain
import BookmarkData
import Detail
import DetailInterface
import DetailDomain
import DetailData
import Search
import SearchInterface
import SearchDomain
import SearchData
import Mypage
import MypageInterface
import MypageDomain
import MypageData
import Launch
import LaunchInterface

@MainActor
enum CompositionRoot {
    private static var container: Container { AppDIContainer.shared.container }

    static func registerGlobalDependencies() {
        let exploreRepo = ExploreNewsletterRepositoryImpl(
            network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
        )
        let exploreUseCase = ExploreNewsletterUseCaseImpl(repository: exploreRepo)
        container.register(LoadOptionsUseCase.self) { _ in
            LoadOptionsUseCaseImpl(newsletterUseCase: exploreUseCase)
        }.inObjectScope(.container)
    }

    static func makeAuthFactory() -> AuthViewFactory {
        let authRepo = AuthRepositoryImpl(
            network: container.resolve(MoyaNetworkService<UserAPI>.self)!
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
                network: container.resolve(MoyaNetworkService<ArticleAPI>.self)!
            )
            let newsletterRepo = HomeNewsletterRepositoryImpl(
                network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
            )
            let fetchUseCase = FetchHomeDataUseCaseImpl(newsletterRepo: newsletterRepo, articleRepo: articleRepo)
            let businessUseCase = DefaultHomeBusinessUseCase(fetchUseCase: fetchUseCase)
            return HomeViewModel(useCase: businessUseCase)
        })
    }

    static func makeExploreFactory() -> ExploreViewFactory {
        return ExploreViewFactoryImpl(viewModelProvider: {
            let repo = ExploreNewsletterRepositoryImpl(
                network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
            )
            let useCase = ExploreNewsletterUseCaseImpl(repository: repo)
            return ExploreViewModel(useCase: useCase)
        })
    }

    static func makeSubscribeFactory() -> SubscribeViewFactory {
        return SubscribeViewFactoryImpl(viewModelProvider: {
            let repo = SubscribeNewsletterRepositoryImpl(
                network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
            )
            let useCase = SubscribeUseCaseImpl(repository: repo)
            return SubscribeViewModel(useCase: useCase)
        })
    }

    static func makeBookmarkFactory() -> BookmarkViewFactory {
        return BookmarkViewFactoryImpl(viewModelProvider: {
            let repo = BookmarkRepositoryImpl(
                network: container.resolve(MoyaNetworkService<ArticleAPI>.self)!
            )
            let useCase = BookmarkUseCaseImpl(repository: repo)
            return BookmarkViewModel(useCase: useCase)
        })
    }

    static func makeDetailFactory() -> DetailViewFactory {
        return DetailViewFactoryImpl(
            brandDetailViewModelProvider: { id in
                let brandRepo = DetailBrandRepositoryImpl(
                    network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
                )
                return BrandDetailViewModel(id: id, brandRepository: brandRepo)
            },
            articleDetailViewModelProvider: { id in
                let articleRepo = DetailArticleRepositoryImpl(
                    network: container.resolve(MoyaNetworkService<ArticleAPI>.self)!
                )
                let detailUseCase = ArticleDetailUseCaseImpl(articleRepository: articleRepo)
                return ArticleDetailViewModel(id: id, articleDetailUseCase: detailUseCase)
            }
        )
    }

    static func makeSearchFactory() -> SearchViewFactory {
        return SearchViewFactoryImpl(viewModelProvider: {
            let repo = SearchRepositoryImpl(
                network: container.resolve(MoyaNetworkService<SearchAPI>.self)!
            )
            let useCase = SearchUseCaseImpl(searchRepository: repo)
            return SearchViewModel(useCase: useCase)
        })
    }

    static func makeMypageFactory() -> MypageViewFactory {
        let userRepo = MypageUserRepositoryImpl(
            network: container.resolve(MoyaNetworkService<UserAPI>.self)!
        )
        let statsRepo = MypageStatsRepositoryImpl(
            articleNetwork: container.resolve(MoyaNetworkService<ArticleAPI>.self)!,
            newsletterNetwork: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
        )
        return MypageViewFactoryImpl(
            mypageViewModelProvider: {
                let userUseCase = MypageUserUseCaseImpl(repository: userRepo)
                let profileUseCase = ProfileUseCaseImpl(userUseCase: userUseCase)
                return MypageViewModel(useCase: userUseCase, profileUseCase: profileUseCase)
            },
            recoveryViewModelProvider: {
                let userUseCase = MypageUserUseCaseImpl(repository: userRepo)
                return RecoveryViewModel(useCase: userUseCase)
            },
            withdrawViewModelProvider: {
                let userUseCase = MypageUserUseCaseImpl(repository: userRepo)
                let statsUseCase = MypageStatsUseCaseImpl(repository: statsRepo)
                return WithdrawViewModel(
                    userUseCase: userUseCase,
                    statsUseCase: statsUseCase
                )
            }
        )
    }

    static func makeLaunchFactory() -> LaunchViewFactory {
        return LaunchViewFactoryImpl()
    }
}
