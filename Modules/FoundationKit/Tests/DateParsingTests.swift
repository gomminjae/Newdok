import Foundation
import Testing
@testable import FoundationKit

struct DateParsingTests {
    @Test("ISO 날짜는 소수 초와 시간대를 보존한다", arguments: [
        ("2025-01-02T03:04:05Z", 1_735_787_045.0),
        ("2025-01-02T03:04:05.123Z", 1_735_787_045.123),
        ("2025-01-02T12:04:05+09:00", 1_735_787_045.0),
        ("2025-01-02T12:04:05.123+09:00", 1_735_787_045.123)
    ])
    func parsesISODate(input: String, expected: TimeInterval) throws {
        let date = try #require(input.newdokISODate)
        #expect(abs(date.timeIntervalSince1970 - expected) < 0.001)
    }

    @Test("잘못된 날짜는 nil을 반환한다", arguments: ["", "invalid", "2025-01-02"])
    func rejectsInvalidDate(input: String) {
        #expect(input.newdokISODate == nil)
    }
}
