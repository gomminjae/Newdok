import Foundation

public struct AuthAgreement: Sendable {
    public enum AgreementType: String, Sendable {
        case ageConfirmationOver14 = "AGE_CONFIRMATION_OVER_14"
        case termsOfService = "TERMS_OF_SERVICE"
        case personalInformation = "PERSONAL_INFORMATION_COLLECTION_AND_USE"
        case marketing = "MARKETING_INFORMATION_RECEIPT"
    }

    public let type: AgreementType
    public let agreed: Bool

    public init(type: AgreementType, agreed: Bool) {
        self.type = type
        self.agreed = agreed
    }
}
