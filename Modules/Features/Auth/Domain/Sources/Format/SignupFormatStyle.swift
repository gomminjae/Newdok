import Foundation

public enum IDValidationError: Error {
    case invalidLengthAndCombination
    case invalidLength
    case invalidCombination

    public var message: String {
        switch self {
        case .invalidLengthAndCombination:
            return "6~12자, 영문/숫자 조합으로 입력해주세요."
        case .invalidLength:
            return "6~12자 이내로 입력해주세요."
        case .invalidCombination:
            return "영문/숫자 조합으로 구성해주세요."
        }
    }
}

public enum NicknameValidationError: Error {
    case invalidLength
    case containsInvalidCharacters

    public var message: String {
        switch self {
        case .invalidLength:
            return "1자 이상 12자 이하로 입력해주세요."
        case .containsInvalidCharacters:
            return "특수문자와 공백은 사용할 수 없습니다."
        }
    }
}

public enum PasswordValidationError: Error {
    case tooShort
    case invalidCombination

    public var message: String {
        switch self {
        case .tooShort:
            return "8자 이상의 비밀번호를 입력해주세요."
        case .invalidCombination:
            return "영문/숫자 조합으로 구성해주세요."
        }
    }
}

public enum PhoneNumberValidationError: Error {
    case invalidLength
    case containsNonDigits

    public var message: String {
        switch self {
        case .invalidLength:
            return "휴대폰 번호 11자리를 입력해주세요."
        case .containsNonDigits:
            return "숫자만 입력해주세요."
        }
    }
}

public enum SignupFormatStyle {
    public static func validateID(_ id: String) -> IDValidationError? {
        let isValidLength = (6...12).contains(id.count)
        let hasLetter = id.rangeOfCharacter(from: .letters) != nil
        let hasNumber = id.rangeOfCharacter(from: .decimalDigits) != nil
        let isAlphanumeric = hasLetter && hasNumber

        let allowedCharset = CharacterSet.alphanumerics
        let containsOnlyAllowed = id.rangeOfCharacter(from: allowedCharset.inverted) == nil

        if !isValidLength && (!isAlphanumeric || !containsOnlyAllowed) {
            return .invalidLengthAndCombination
        }
        if !isValidLength { return .invalidLength }
        if !isAlphanumeric || !containsOnlyAllowed { return .invalidCombination }
        return nil
    }

    public static func validateNickname(_ nickname: String) -> NicknameValidationError? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty || trimmed.count > 12 {
            return .invalidLength
        }

        let regex = "^[a-zA-Z0-9가-힣]+$"
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed) {
            return .containsInvalidCharacters
        }

        return nil
    }

    public static func validatePassword(_ password: String) -> PasswordValidationError? {
        let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        let isValidLength = password.count >= 8 && password.count <= 20

        if !isValidLength { return .tooShort }
        if !(hasLetter && hasDigit) { return .invalidCombination }
        return nil
    }

    public static func validatePhoneNumber(_ phoneNumber: String) -> PhoneNumberValidationError? {
        let digitsOnly = phoneNumber.allSatisfy(\.isNumber)
        if !digitsOnly { return .containsNonDigits }
        if phoneNumber.count != 11 { return .invalidLength }
        return nil
    }
}
