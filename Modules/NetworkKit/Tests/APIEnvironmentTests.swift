import Foundation
import Testing
@testable import NetworkKit

struct APIEnvironmentTests {
    @Test("API URL은 경로와 포트를 보존한다", arguments: [
        "https://example.com/v1",
        "http://localhost:8080/api"
    ])
    func preservesBasePath(raw: String) throws {
        let url = try #require(APIEnvironment.validatedBaseURL(" \(raw)\n"))
        #expect(url.absoluteString == raw)
        #expect(url.appendingPathComponent("articles").absoluteString == "\(raw)/articles")
    }

    @Test("잘못된 API URL 설정은 거부한다", arguments: [
        "", "$(API_BASE_URL)", "example.com", "file:///tmp/api", "https://",
        "https://user:password@example.com", "https://example.com?token=value",
        "https://example.com#fragment"
    ])
    func rejectsInvalidBaseURL(raw: String) {
        #expect(APIEnvironment.validatedBaseURL(raw) == nil)
    }
}
