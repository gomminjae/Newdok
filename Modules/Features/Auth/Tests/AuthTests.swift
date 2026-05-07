import Testing
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
