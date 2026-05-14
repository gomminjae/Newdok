import Foundation

private enum NewdokDateFormatters {
    static let homeDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter
    }()
}

public extension Date {
    var newdokHomeDisplayText: String {
        NewdokDateFormatters.homeDisplay.string(from: self)
    }

    var newdokYearString: String {
        String(newdokDateComponents.year ?? 0)
    }

    var newdokMonthString: String {
        String(format: "%02d", newdokDateComponents.month ?? 0)
    }

    var newdokDayString: String {
        String(format: "%02d", newdokDateComponents.day ?? 0)
    }

    var newdokMonthKey: String {
        "\(newdokYearString)-\(newdokMonthString)"
    }

    var newdokDayKey: String {
        "\(newdokMonthKey)-\(newdokDayString)"
    }

    private var newdokDateComponents: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
}
