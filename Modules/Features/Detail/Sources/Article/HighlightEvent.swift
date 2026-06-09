import Foundation
import DetailDomain

enum HighlightEvent: Equatable {
    case selected(text: String)
    case applied(text: String, style: HighlightStyle)
    case styleChanged(text: String, to: HighlightStyle)
    case deleted(text: String)

    init?(messageBody: Any) {
        guard let dict = messageBody as? [String: Any],
              let type = dict["type"] as? String,
              let payload = dict["payload"] as? [String: Any] else {
            return nil
        }
        let text = payload["text"] as? String ?? ""

        switch type {
        case "selected":
            self = .selected(text: text)
        case "applied":
            guard let style = Self.style(payload) else { return nil }
            self = .applied(text: text, style: style)
        case "styleChanged":
            guard let style = Self.style(payload) else { return nil }
            self = .styleChanged(text: text, to: style)
        case "deleted":
            self = .deleted(text: text)
        default:
            return nil
        }
    }

    private static func style(_ payload: [String: Any]) -> HighlightStyle? {
        (payload["style"] as? String).flatMap(HighlightStyle.init(rawValue:))
    }
}
