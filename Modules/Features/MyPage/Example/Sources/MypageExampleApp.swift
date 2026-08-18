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
            selectableItemStore: SelectableItemStore.shared,
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
