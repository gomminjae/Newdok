import FoundationKit

public typealias IDValidationError = NewdokIDValidationError
public typealias NicknameValidationError = NewdokNicknameValidationError
public typealias PasswordValidationError = NewdokPasswordValidationError
public typealias PhoneNumberValidationError = NewdokPhoneNumberValidationError

public enum SignupFormatStyle {
    public static func validateID(_ id: String) -> IDValidationError? {
        NewdokInputValidator.validateID(id)
    }

    public static func validateNickname(_ nickname: String) -> NicknameValidationError? {
        NewdokInputValidator.validateNickname(nickname)
    }

    public static func validatePassword(_ password: String) -> PasswordValidationError? {
        NewdokInputValidator.validatePassword(password)
    }

    public static func validatePhoneNumber(_ phoneNumber: String) -> PhoneNumberValidationError? {
        NewdokInputValidator.validatePhoneNumber(phoneNumber)
    }
}
