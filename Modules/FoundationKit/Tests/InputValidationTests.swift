import Testing
@testable import FoundationKit

struct InputValidationTests {
    @Test("닉네임은 완성형 한글과 ASCII 영문·숫자만 허용한다")
    func nicknameCharacterBoundary() {
        #expect(NewdokInputValidator.containsOnlyNicknameCharacters("뉴독user1"))
        #expect(!NewdokInputValidator.containsOnlyNicknameCharacters(""))
        #expect(!NewdokInputValidator.containsOnlyNicknameCharacters("a\u{301}"))
        #expect(!NewdokInputValidator.containsOnlyNicknameCharacters("가"))
        #expect(!NewdokInputValidator.containsOnlyNicknameCharacters("hello\n"))
    }

    @Test("비밀번호는 ASCII 영문·숫자를 Unicode scalar 기준으로 검사한다")
    func passwordCharacterBoundary() {
        #expect(NewdokInputValidator.validatePassword("a\u{301}1234567") == nil)
        #expect(NewdokInputValidator.validatePassword("가나다라1234") == .invalidCombination)
        #expect(NewdokInputValidator.validatePassword("abcd１２３４") == .invalidCombination)
    }
}
