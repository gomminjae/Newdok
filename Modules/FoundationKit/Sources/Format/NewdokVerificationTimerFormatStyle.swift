import Foundation

public struct NewdokVerificationTimerFormatStyle: FormatStyle {
    public typealias FormatInput = Int
    public typealias FormatOutput = String

    public init() {}

    public func format(_ value: Int) -> String {
        let clamped = max(0, value)
        return String(format: "%02d:%02d", clamped / 60, clamped % 60)
    }
}

public extension FormatStyle where Self == NewdokVerificationTimerFormatStyle {
    static var newdokVerificationTimer: NewdokVerificationTimerFormatStyle {
        NewdokVerificationTimerFormatStyle()
    }
}
