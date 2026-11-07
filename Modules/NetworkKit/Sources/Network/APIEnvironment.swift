import Foundation

public enum APIEnvironment {
    public static let baseURL: URL = {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String else {
            fatalError("Info.plist에 API_BASE_URL이 없습니다. xcconfig 설정을 확인하세요.")
        }
        guard let url = validatedBaseURL(raw) else {
            preconditionFailure("API_BASE_URL은 올바른 HTTP(S) URL이어야 합니다. xcconfig 설정을 확인하세요.")
        }
        return url
    }()

    static func validatedBaseURL(_ raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil,
              components.query == nil, components.fragment == nil else { return nil }
        return components.url
    }
}
