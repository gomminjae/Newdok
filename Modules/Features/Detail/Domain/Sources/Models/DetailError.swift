import Foundation

public enum DetailError: Error, LocalizedError {
    case brandNotFound
    case alreadyPaused
    case alreadyActive

    public var errorDescription: String? {
        switch self {
        case .brandNotFound:
            return "뉴스레터를 찾을 수 없습니다"
        case .alreadyPaused:
            return "이미 구독이 중지된 뉴스레터입니다"
        case .alreadyActive:
            return "이미 구독 중인 뉴스레터입니다"
        }
    }
}
