public enum SubscriptionStatus: Sendable, Equatable {
    case initial
    case check
    case confirmed
    case paused
    case unknown

    public init(serverValue: String) {
        switch serverValue.uppercased() {
        case "INITIAL": self = .initial
        case "CHECK": self = .check
        case "CONFIRMED": self = .confirmed
        case "PAUSED": self = .paused
        default: self = .unknown
        }
    }
}
