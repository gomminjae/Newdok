import Foundation

public enum SubscribeError: Error, LocalizedError {
    case alreadyPaused
    case alreadyActive

    public var errorDescription: String? {
        switch self {
        case .alreadyPaused:
            return "이미 구독이 중지된 뉴스레터입니다"
        case .alreadyActive:
            return "이미 구독 중인 뉴스레터입니다"
        }
    }
}
