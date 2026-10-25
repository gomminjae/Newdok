import SwiftUI
import Shared
import DesignSystem
import Mypage
import MypageDomain
import MypageTesting

@main
struct MypageExampleApp: App {
    init() {
        AppState.shared.login()
        UserInfoStore.shared.save(.sample)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MypageView(
                    viewModel: makeViewModel(),
                    onEditProfile: {},
                    onEditAlert: {},
                    onFAQ: {},
                    onFeedback: {},
                    onTermsMenu: {},
                    onLogout: {},
                    onWithdraw: {}
                )
            }
            .environment(AppState.shared)
            .environment(ToastCenter.shared)
        }
    }

    @MainActor
    private func makeViewModel() -> MypageViewModel {
        let profile = MockFetchMypageProfileUseCase()
        profile.result = .success(SampleMypageUsers.standard)

        return MypageViewModel(
            fetchProfileUseCase: profile,
            updateNicknameUseCase: MockUpdateMypageNicknameUseCase(),
            updateInterestsUseCase: MockUpdateMypageInterestsUseCase(),
            updateIndustryUseCase: MockUpdateMypageIndustryUseCase(),
            selectableItemStore: SelectableItemStore(fetchOptionsUseCase: ExampleOptionsFetcher()),
            userInfoStore: UserInfoStore.shared
        )
    }
}

private extension UserInfo {
    static let sample = UserInfo(
        id: 1,
        subscribeEmail: "newdok@example.com",
        nickname: "뉴독러",
        birthYear: "1995",
        gender: "F",
        createdAt: "2025-01-01",
        industryId: 1,
        interestIds: [1, 2, 3]
    )
}

private struct ExampleOptionsFetcher: FetchSelectableOptionsUseCase {
    func execute() async throws -> SelectableOptions {
        SelectableOptions(
            interests: [.init(id: 1, name: "경제·시사"), .init(id: 2, name: "비즈니스"), .init(id: 3, name: "과학·기술")],
            industries: [.init(id: 1, name: "IT")],
            days: [.init(id: 1, name: "월요일")]
        )
    }
}
