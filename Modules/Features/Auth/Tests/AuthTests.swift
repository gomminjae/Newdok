import Testing
import Shared
@testable import AuthDomain

@Suite("SignupFormatStyle Tests")
struct SignupFormatStyleTests {

    // MARK: - validateID

    @Test("빈 문자열은 길이+조합 오류")
    func validateID_empty() {
        #expect(SignupFormatStyle.validateID("") == .invalidLengthAndCombination)
    }

    @Test("5자 영문+숫자 — 길이 오류")
    func validateID_tooShort() {
        #expect(SignupFormatStyle.validateID("abc12") == .invalidLength)
    }

    @Test("13자 영문+숫자 — 길이 오류")
    func validateID_tooLong() {
        #expect(SignupFormatStyle.validateID("abcdef1234567") == .invalidLength)
    }

    @Test("숫자만 6자 — 조합 오류")
    func validateID_digitsOnly() {
        #expect(SignupFormatStyle.validateID("123456") == .invalidCombination)
    }

    @Test("영문만 6자 — 조합 오류")
    func validateID_lettersOnly() {
        #expect(SignupFormatStyle.validateID("abcdef") == .invalidCombination)
    }

    @Test("특수문자 포함 6자 — 조합 오류")
    func validateID_specialChars() {
        #expect(SignupFormatStyle.validateID("abc!@#") == .invalidCombination)
    }

    @Test("3자 숫자만 — 길이+조합 오류")
    func validateID_shortAndInvalidCombo() {
        #expect(SignupFormatStyle.validateID("123") == .invalidLengthAndCombination)
    }

    @Test("정상 입력 — nil")
    func validateID_valid() {
        #expect(SignupFormatStyle.validateID("test12") == nil)
        #expect(SignupFormatStyle.validateID("user123abc") == nil)
        #expect(SignupFormatStyle.validateID("abcdef123456") == nil)
    }

    // MARK: - validateNickname

    @Test("빈 문자열 — 길이 오류")
    func validateNickname_empty() {
        #expect(SignupFormatStyle.validateNickname("") == .invalidLength)
    }

    @Test("공백만 — 길이 오류")
    func validateNickname_whitespaceOnly() {
        #expect(SignupFormatStyle.validateNickname("   ") == .invalidLength)
    }

    @Test("13자 — 길이 오류")
    func validateNickname_tooLong() {
        #expect(SignupFormatStyle.validateNickname("abcdefghijklm") == .invalidLength)
    }

    @Test("특수문자 포함 — 문자 오류")
    func validateNickname_specialChars() {
        #expect(SignupFormatStyle.validateNickname("hello!") == .containsInvalidCharacters)
    }

    @Test("공백 포함 — 문자 오류")
    func validateNickname_containsSpace() {
        #expect(SignupFormatStyle.validateNickname("hello world") == .containsInvalidCharacters)
    }

    @Test("한글 정상")
    func validateNickname_korean() {
        #expect(SignupFormatStyle.validateNickname("뉴독사용자") == nil)
    }

    @Test("영문 정상")
    func validateNickname_english() {
        #expect(SignupFormatStyle.validateNickname("newdok") == nil)
    }

    @Test("숫자 정상")
    func validateNickname_numbers() {
        #expect(SignupFormatStyle.validateNickname("user123") == nil)
    }

    @Test("한글+영문+숫자 혼합 정상")
    func validateNickname_mixed() {
        #expect(SignupFormatStyle.validateNickname("뉴독user1") == nil)
    }

    @Test("12자 경계값 정상")
    func validateNickname_exactMax() {
        #expect(SignupFormatStyle.validateNickname("123456789012") == nil)
    }

    @Test("1자 경계값 정상")
    func validateNickname_singleChar() {
        #expect(SignupFormatStyle.validateNickname("a") == nil)
    }

    // MARK: - validatePassword

    @Test("빈 문자열 — tooShort")
    func validatePassword_empty() {
        #expect(SignupFormatStyle.validatePassword("") == .tooShort)
    }

    @Test("7자 영문+숫자 — tooShort")
    func validatePassword_tooShort() {
        #expect(SignupFormatStyle.validatePassword("abc1234") == .tooShort)
    }

    @Test("21자 — tooShort")
    func validatePassword_tooLong() {
        #expect(SignupFormatStyle.validatePassword("abcdefghij12345678901") == .tooShort)
    }

    @Test("숫자만 8자 — invalidCombination")
    func validatePassword_digitsOnly() {
        #expect(SignupFormatStyle.validatePassword("12345678") == .invalidCombination)
    }

    @Test("영문만 8자 — invalidCombination")
    func validatePassword_lettersOnly() {
        #expect(SignupFormatStyle.validatePassword("abcdefgh") == .invalidCombination)
    }

    @Test("영문+숫자 8자 정상")
    func validatePassword_valid() {
        #expect(SignupFormatStyle.validatePassword("abcd1234") == nil)
    }

    @Test("영문+숫자 20자 경계값 정상")
    func validatePassword_exactMax() {
        #expect(SignupFormatStyle.validatePassword("abcdefghij1234567890") == nil)
    }

    // MARK: - validatePhoneNumber

    @Test("빈 문자열 — invalidLength")
    func validatePhone_empty() {
        #expect(SignupFormatStyle.validatePhoneNumber("") == .invalidLength)
    }

    @Test("10자리 — invalidLength")
    func validatePhone_tooShort() {
        #expect(SignupFormatStyle.validatePhoneNumber("0101234567") == .invalidLength)
    }

    @Test("12자리 — invalidLength")
    func validatePhone_tooLong() {
        #expect(SignupFormatStyle.validatePhoneNumber("010123456789") == .invalidLength)
    }

    @Test("하이픈 포함 — containsNonDigits")
    func validatePhone_withHyphen() {
        #expect(SignupFormatStyle.validatePhoneNumber("010-1234-567") == .containsNonDigits)
    }

    @Test("문자 포함 — containsNonDigits")
    func validatePhone_withLetters() {
        #expect(SignupFormatStyle.validatePhoneNumber("0101234abcd") == .containsNonDigits)
    }

    @Test("11자리 숫자 정상")
    func validatePhone_valid() {
        #expect(SignupFormatStyle.validatePhoneNumber("01012345678") == nil)
    }
}

@Suite("NewdokInputValidator Tests")
struct NewdokInputValidatorTests {

    // MARK: - ID

    @Test("아이디는 6~12자 영문/숫자 조합만 허용")
    func validateID() {
        #expect(NewdokInputValidator.validateID("") == .invalidLengthAndCombination)
        #expect(NewdokInputValidator.validateID("abc12") == .invalidLength)
        #expect(NewdokInputValidator.validateID("abcdef1234567") == .invalidLength)
        #expect(NewdokInputValidator.validateID("123456") == .invalidCombination)
        #expect(NewdokInputValidator.validateID("abcdef") == .invalidCombination)
        #expect(NewdokInputValidator.validateID("abc!@#") == .invalidCombination)
        #expect(NewdokInputValidator.validateID("test12") == nil)
    }

    // MARK: - Nickname

    @Test("닉네임은 1~12자 한글/영문/숫자만 허용")
    func validateNickname() {
        #expect(NewdokInputValidator.validateNickname("") == .invalidLength)
        #expect(NewdokInputValidator.validateNickname("   ") == .invalidLength)
        #expect(NewdokInputValidator.validateNickname("abcdefghijklm") == .invalidLength)
        #expect(NewdokInputValidator.validateNickname("hello!") == .containsInvalidCharacters)
        #expect(NewdokInputValidator.validateNickname("hello world") == .containsInvalidCharacters)
        #expect(NewdokInputValidator.validateNickname("뉴독user1") == nil)
        #expect(NewdokInputValidator.containsOnlyNicknameCharacters("뉴독user1"))
        #expect(!NewdokInputValidator.containsOnlyNicknameCharacters("뉴독 user!"))
    }

    // MARK: - Password

    @Test("비밀번호는 8~20자 영문/숫자 조합")
    func validatePassword() {
        #expect(NewdokInputValidator.validatePassword("") == .tooShort)
        #expect(NewdokInputValidator.validatePassword("abc1234") == .tooShort)
        #expect(NewdokInputValidator.validatePassword("abcdefghij12345678901") == .tooShort)
        #expect(NewdokInputValidator.validatePassword("12345678") == .invalidCombination)
        #expect(NewdokInputValidator.validatePassword("abcdefgh") == .invalidCombination)
        #expect(NewdokInputValidator.validatePassword("abcd1234") == nil)
        #expect(NewdokInputValidator.validatePassword("abcdefghij1234567890") == nil)
    }

    // MARK: - Phone Number

    @Test("휴대폰 번호는 숫자 11자리만 허용")
    func validatePhoneNumber() {
        #expect(NewdokInputValidator.validatePhoneNumber("") == .invalidLength)
        #expect(NewdokInputValidator.validatePhoneNumber("0101234567") == .invalidLength)
        #expect(NewdokInputValidator.validatePhoneNumber("010123456789") == .invalidLength)
        #expect(NewdokInputValidator.validatePhoneNumber("010-1234-567") == .containsNonDigits)
        #expect(NewdokInputValidator.validatePhoneNumber("0101234abcd") == .containsNonDigits)
        #expect(NewdokInputValidator.validatePhoneNumber("01012345678") == nil)
    }

    // MARK: - Digits

    @Test("문자열에서 숫자만 추출하고 제한 길이를 적용")
    func digitsOnly() {
        #expect("010-1234-abcd5678".newdokDigitsOnly() == "01012345678")
        #expect("010-1234-abcd5678".newdokDigitsOnly(limit: 6) == "010123")
        #expect("abcdef".newdokDigitsOnly() == "")
    }
}

@Suite("NewdokVerificationTimerFormatStyle Tests")
struct NewdokVerificationTimerFormatStyleTests {
    private let style = NewdokVerificationTimerFormatStyle()

    @Test("초를 MM:ss 형식으로 포맷")
    func formatSeconds() {
        #expect(style.format(0) == "00:00")
        #expect(style.format(1) == "00:01")
        #expect(style.format(59) == "00:59")
        #expect(style.format(60) == "01:00")
        #expect(style.format(180) == "03:00")
    }

    @Test("음수는 0초로 보정")
    func formatNegativeSeconds() {
        #expect(style.format(-1) == "00:00")
    }
}
