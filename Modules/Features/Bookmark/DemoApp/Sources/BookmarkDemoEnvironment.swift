import Foundation
import Core
import Data
import Domain
import Shared

@MainActor
final class BookmarkDemoEnvironment: ObservableObject {
    enum State {
        case loading
        case loaded(useCase: ArticleUseCase)
        case failed(message: String)
    }

    @Published private(set) var state: State = .loading

    private let networkProvider = NetworkProvider()
    private let demoLoginId = "test6889"
    private let demoPassword = "test6889"

    init() {
        Task {
            await initializeDemoSession()
        }
    }

    func retry() {
        state = .loading
        Task {
            await initializeDemoSession()
        }
    }

    private func initializeDemoSession() async {
        do {
            resetSession()

            let authProvider = networkProvider.makeAuthProvider()
            let articleProvider = networkProvider.makeArticleProvider()

            let userRepository = UserRepositoryImpl(provider: authProvider)
            let userUseCase = UserUseCaseImpl(userRepository: userRepository)

            let (user, token) = try await userUseCase.login(loginId: demoLoginId, password: demoPassword)

            TokenStorage.accessToken = token
            AppState.shared.login()

            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(false, forKey: "isGuest")
            UserDefaults.standard.set(user.nickname, forKey: "nickname")
            UserDefaults.standard.set(user.subscribeEmail ?? "", forKey: "email")

            let userInfo = UserInfo(
                id: user.id,
                loginId: user.loginId,
                phoneNumber: user.phoneNumber,
                subscribeEmail: user.subscribeEmail,
                nickname: user.nickname,
                birthYear: user.birthYear,
                gender: user.gender,
                createdAt: user.createdAt,
                industryId: user.industryId,
                interestIds: user.interests.map { $0.id }
            )
            UserInfoStore.shared.save(userInfo)

            let articleRepository = ArticleRepositoryImpl(provider: articleProvider)
            let articleUseCase = ArticleUseCaseImpl(articleRepository: articleRepository)

            state = .loaded(useCase: articleUseCase)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    private func resetSession() {
        TokenStorage.clear()
        AppState.shared.logout()
        UserDefaults.standard.set(true, forKey: "isGuest")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "nickname")
        UserDefaults.standard.removeObject(forKey: "email")
        UserInfoStore.shared.clear()
    }
}
