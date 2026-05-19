import Testing
import Foundation
@testable import Mypage
@testable import MypageTesting
@testable import MypageDomain

@Suite("MypageViewModel Tests")
@MainActor
struct MypageViewModelTests {
    private func makeSUT() -> (
        vm: MypageViewModel,
        fetchProfile: MockFetchMypageProfileUseCase,
        updateNickname: MockUpdateMypageNicknameUseCase,
        updatePassword: MockUpdateMypagePasswordUseCase,
        updateInterests: MockUpdateMypageInterestsUseCase,
        updateIndustry: MockUpdateMypageIndustryUseCase,
        updatePhoneNumber: MockUpdateMypagePhoneNumberUseCase,
        authSMS: MockMypageAuthSMSUseCase
    ) {
        let fetchProfile = MockFetchMypageProfileUseCase()
        let updateNickname = MockUpdateMypageNicknameUseCase()
        let updatePassword = MockUpdateMypagePasswordUseCase()
        let updateInterests = MockUpdateMypageInterestsUseCase()
        let updateIndustry = MockUpdateMypageIndustryUseCase()
        let updatePhoneNumber = MockUpdateMypagePhoneNumberUseCase()
        let authSMS = MockMypageAuthSMSUseCase()
        let vm = MypageViewModel(
            fetchProfileUseCase: fetchProfile,
            updateNicknameUseCase: updateNickname,
            updatePasswordUseCase: updatePassword,
            updateInterestsUseCase: updateInterests,
            updateIndustryUseCase: updateIndustry,
            updatePhoneNumberUseCase: updatePhoneNumber,
            authSMSUseCase: authSMS
        )
        return (vm, fetchProfile, updateNickname, updatePassword, updateInterests, updateIndustry, updatePhoneNumber, authSMS)
    }

    @Test func fetchUserInfo_success() async {
        let (vm, fetchProfile, _, _, _, _, _, _) = makeSUT()
        let user = MypageUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil, nickname: "닉네임", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])
        fetchProfile.result = .success(user)

        await vm.fetchuserInfo()

        #expect(fetchProfile.executeCallCount == 1)
        #expect(vm.user?.nickname == "닉네임")
    }

    @Test func updateNickname_success() async {
        let (vm, _, updateNickname, _, _, _, _, _) = makeSUT()
        vm.user = MypageUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil, nickname: "이전", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateNickname(nickname: "새닉네임")

        #expect(success == true)
        #expect(updateNickname.executedNickname == "새닉네임")
        #expect(vm.showNicknameSuccess == true)
    }

    @Test func updateNickname_failure() async {
        let (vm, _, updateNickname, _, _, _, _, _) = makeSUT()
        updateNickname.result = .failure(NSError(domain: "test", code: -1))

        let success = await vm.updateNickname(nickname: "새닉네임")

        #expect(success == false)
    }

    @Test func updateIndustry_success() async {
        let (vm, _, _, _, _, updateIndustry, _, _) = makeSUT()
        vm.user = MypageUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil, nickname: "테스트", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateIndustry(id: 5)

        #expect(success == true)
        #expect(updateIndustry.executedId == 5)
        #expect(vm.showIndustrySuccess == true)
    }

    @Test func updateInterests_success() async {
        let (vm, _, _, _, updateInterests, _, _, _) = makeSUT()
        vm.user = MypageUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil, nickname: "테스트", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])

        let success = await vm.updateInterests(ids: [1, 2, 3])

        #expect(success == true)
        #expect(updateInterests.executedIds == [1, 2, 3])
        #expect(vm.showInterestSuccess == true)
    }

    @Test func sendVerificationCode_success() async {
        let (vm, _, _, _, _, _, _, authSMS) = makeSUT()
        vm.phoneNumber = "01012345678"

        await vm.sendVerificationCode()

        #expect(authSMS.executedPhoneNumber == "01012345678")
        #expect(vm.isRequestSent == true)
    }
}

@Suite("WithdrawViewModel Tests")
@MainActor
struct WithdrawViewModelTests {
    private func makeSUT() -> (
        vm: WithdrawViewModel,
        fetchProfile: MockFetchMypageProfileUseCase,
        fetchSubCount: MockFetchMypageSubscriptionCountUseCase,
        fetchArticleCount: MockFetchReceivedArticleCountUseCase,
        withdraw: MockMypageWithdrawUseCase
    ) {
        let fetchProfile = MockFetchMypageProfileUseCase()
        let fetchSubCount = MockFetchMypageSubscriptionCountUseCase()
        let fetchArticleCount = MockFetchReceivedArticleCountUseCase()
        let withdraw = MockMypageWithdrawUseCase()
        let vm = WithdrawViewModel(
            fetchProfileUseCase: fetchProfile,
            fetchSubscriptionCountUseCase: fetchSubCount,
            fetchArticleCountUseCase: fetchArticleCount,
            withdrawUseCase: withdraw
        )
        return (vm, fetchProfile, fetchSubCount, fetchArticleCount, withdraw)
    }

    @Test func fetchUserInfo_success() async {
        let (vm, fetchProfile, fetchSubCount, fetchArticleCount, _) = makeSUT()
        fetchProfile.result = .success(
            MypageUser(id: 1, loginId: "test", phoneNumber: "010", subscribeEmail: nil, nickname: "유저", birthYear: "2000", gender: "M", createdAt: "2025-01-01", industryId: 1, interests: [])
        )
        fetchSubCount.result = .success(3)
        fetchArticleCount.result = .success(15)

        await vm.fetchUserInfo()

        #expect(vm.nickName == "유저")
        #expect(vm.newsletterCount == 3)
        #expect(vm.articleCount == 15)
    }

    @Test func withdraw_success() async {
        let (vm, _, _, _, withdraw) = makeSUT()

        await vm.withdraw()

        #expect(withdraw.executeCallCount == 1)
        #expect(vm.withdrawSuccess == true)
    }
}

@Suite("RecoveryViewModel Tests")
@MainActor
struct RecoveryViewModelTests {
    private func makeSUT() -> (
        vm: RecoveryViewModel,
        checkPhone: MockCheckMypagePhoneNumberUseCase,
        checkIDDup: MockCheckMypageIDDupUseCase,
        authSMS: MockMypageAuthSMSUseCase,
        resetPassword: MockResetMypagePasswordUseCase
    ) {
        let checkPhone = MockCheckMypagePhoneNumberUseCase()
        let checkIDDup = MockCheckMypageIDDupUseCase()
        let authSMS = MockMypageAuthSMSUseCase()
        let resetPassword = MockResetMypagePasswordUseCase()
        let vm = RecoveryViewModel(
            checkPhoneNumberUseCase: checkPhone,
            checkIDDupUseCase: checkIDDup,
            authSMSUseCase: authSMS,
            resetPasswordUseCase: resetPassword
        )
        return (vm, checkPhone, checkIDDup, authSMS, resetPassword)
    }

    @Test func findMyIds_success() async {
        let (vm, checkPhone, _, _, _) = makeSUT()
        let users = [MypageSimpleUser(id: 1, loginId: "user1", phoneNumber: "010", createdAt: "2025-01-01")]
        checkPhone.result = .success(users)
        vm.phoneNumber = "01012345678"

        await vm.findMyIds()

        #expect(checkPhone.executedPhoneNumber == "01012345678")
        #expect(vm.users.count == 1)
    }

    @Test func checkIdExists_found() async {
        let (vm, _, checkIDDup, _, _) = makeSUT()
        let user = MypageSimpleUser(id: 1, loginId: "found", phoneNumber: "010", createdAt: "2025-01-01")
        checkIDDup.result = .success(.exists(user))
        vm.recoveryId = "found"

        let result = await vm.checkIdExists()

        #expect(result?.loginId == "found")
    }

    @Test func checkIdExists_notFound() async {
        let (vm, _, checkIDDup, _, _) = makeSUT()
        checkIDDup.result = .success(.notFound)
        vm.recoveryId = "none"

        let result = await vm.checkIdExists()

        #expect(result == nil)
    }

    @Test func resetPassword_success() async {
        let (vm, _, _, _, resetPassword) = makeSUT()
        vm.recoveryId = "testUser"
        vm.newPassword = "newPass123!"

        await vm.resetPassword()

        #expect(resetPassword.executedLoginId == "testUser")
        #expect(resetPassword.executedNewPassword == "newPass123!")
        #expect(vm.passwordResetSuccess == true)
    }
}
