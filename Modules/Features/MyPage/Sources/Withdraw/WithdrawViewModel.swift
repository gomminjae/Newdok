import Foundation
import MypageDomain
import Shared

@MainActor
public final class WithdrawViewModel: ObservableObject, ErrorHandling {
    @Published public var nickName: String = ""
    @Published public var newsletterCount: Int = 0
    @Published public var articleCount: Int = 0
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var withdrawSuccess: Bool = false
    @Published public var currentError: AppError?

    private let userUseCase: MypageUserUseCase
    private let statsUseCase: MypageStatsUseCase
    private let tokenStorage: TokenStorable
    private let userInfoStore: UserInfoStorable
    private let sessionStore: SessionStorable

    public init(
        userUseCase: MypageUserUseCase,
        statsUseCase: MypageStatsUseCase,
        tokenStorage: TokenStorable,
        userInfoStore: UserInfoStorable,
        sessionStore: SessionStorable
    ) {
        self.userUseCase = userUseCase
        self.statsUseCase = statsUseCase
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.sessionStore = sessionStore
    }

    public func fetchUserInfo() async {
        await performAsync(feature: "withdraw", operation: "fetchUserInfo", loadingBinding: \.isLoading) {
            let user = try await userUseCase.getProfile()
            self.nickName = user.nickname

            self.newsletterCount = try await statsUseCase.fetchSubscriptionCount()
            self.articleCount = try await statsUseCase.fetchReceivedArticleCount()
        }
    }

    public func withdraw() async {
        await performAsync(feature: "withdraw", operation: "withdraw", loadingBinding: \.isLoading) {
            try await userUseCase.withdraw()

            tokenStorage.clear()
            userInfoStore.clear()
            sessionStore.clearSession()

            NotificationCenter.default.post(name: .init("ResetMypageCache"), object: nil)

            self.withdrawSuccess = true
        }
    }
}
