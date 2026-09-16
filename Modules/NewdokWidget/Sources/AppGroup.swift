import Foundation

enum AppGroup {
    static var identifier: String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_ID") as? String else {
            return nil
        }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else { return nil }
        return trimmedValue
    }
}
