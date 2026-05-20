import SwiftUI
import Shared
import DesignSystem
import Mypage
import MypageDomain
import MypageTesting

@main
struct MypageExampleApp: App {
    @State private var router = AppRouter()
    @State private var tabSelection = TabSelection()

    init() {
        AppState.shared.login()
        UserInfoStore.shared.save(.sample)
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MypageView(viewModel: makeViewModel())
            }
            .environment(router)
            .environment(tabSelection)
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
            updatePasswordUseCase: MockUpdateMypagePasswordUseCase(),
            updateInterestsUseCase: MockUpdateMypageInterestsUseCase(),
            updateIndustryUseCase: MockUpdateMypageIndustryUseCase(),
            updatePhoneNumberUseCase: MockUpdateMypagePhoneNumberUseCase(),
            authSMSUseCase: MockMypageAuthSMSUseCase()
        )
    }
}
