import Foundation
import Swinject
import Core
import Shared
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
import DatabaseKit
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

    static func registerGlobalDependencies() {}

    static func makeLoadOptionsUseCase() -> LoadOptionsUseCase {
        let exploreRepo = ExploreNewsletterRepositoryImpl(
            network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
        )
        return LoadOptionsUseCaseImpl(repository: exploreRepo, selectableItemStore: SelectableItemStore.shared)
    }

    private static let authRepository: AuthRepository = AuthRepositoryImpl(
        network: AppDIContainer.shared.container.resolve(MoyaNetworkService<UserAPI>.self)!
    )

    static func makeAuthFactory() -> AuthViewFactory {
        let authRepo = authRepository
        return AuthViewFactoryImpl(
            signupViewModelProvider: {
                let signupUseCase = SignupUseCaseImpl(authRepository: authRepo)
                return SignupViewModel(authRepository: authRepo, signupUseCase: signupUseCase)
            },
            loginViewModelProvider: {
                let loginUseCase = LoginUseCaseImpl(authRepository: authRepo)
                return LoginViewModel(loginUseCase: loginUseCase)
            }
        )
    }

    static func makeSignOut() -> @MainActor () async -> Void {
        let repo = authRepository
        return { await repo.signOut() }
    }

    static func makeHomeFactory() -> HomeViewFactory {
        return HomeViewFactoryImpl(viewModelProvider: {
            let articleRepo = HomeArticleRepositoryImpl(
                network: container.resolve(MoyaNetworkService<ArticleAPI>.self)!
            )
            let newsletterRepo = HomeNewsletterRepositoryImpl(
                network: container.resolve(MoyaNetworkService<NewsletterAPI>.self)!
            )
            let highlightRepo = HighlightCountRepositoryImpl(dataSource: DefaultHighlightLocalDataSource.shared)
            let businessUseCase = DefaultHomeBusinessUseCase(articleRepository: articleRepo, newsletterRepository: newsletterRepo, highlightCountRepository: highlightRepo)
            return HomeViewModel(useCase: businessUseCase, appState: AppState.shared)
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
                let highlightRepo = DetailHighlightRepositoryImpl(dataSource: DefaultHighlightLocalDataSource.shared)
                return ArticleDetailViewModel(id: id, articleDetailUseCase: detailUseCase, highlightRepository: highlightRepo)
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
                let profileUseCase = ProfileUseCaseImpl(repository: userRepo)
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
