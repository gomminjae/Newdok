import Foundation

public enum APIEnvironment {
    private static let fallbackBaseURL = "http://3.38.79.19"

    public static let baseURL: String = {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            return fallbackBaseURL
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("$(") else {
            fatalError("API_BASE_URL이 치환되지 않았습니다(\(trimmed)). xcconfig 변수 설정을 확인하세요.")
        }
        return trimmed
    }()
}
