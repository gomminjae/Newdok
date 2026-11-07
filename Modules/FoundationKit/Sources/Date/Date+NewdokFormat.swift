import Foundation

private enum NewdokDateFormatters {
    static let homeDisplay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter
    }()

    static let joinDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static let articleDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "M월 d일 (E) a h:mm"
        return formatter
    }()

    static let time: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()

    static let highlightDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}

private enum NewdokISODateParsers {
    static let withFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    static let internetDateTime = Date.ISO8601FormatStyle()
}

public extension String {
    var newdokISODate: Date? {
        (try? NewdokISODateParsers.withFractionalSeconds.parse(self))
            ?? (try? NewdokISODateParsers.internetDateTime.parse(self))
    }
}

public extension Date {
    var newdokHomeDisplayText: String {
        NewdokDateFormatters.homeDisplay.string(from: self)
    }

    var newdokJoinDateText: String {
        NewdokDateFormatters.joinDate.string(from: self)
    }

    var newdokArticleDateTimeText: String {
        NewdokDateFormatters.articleDateTime.string(from: self)
    }

    var newdokTimeText: String {
        NewdokDateFormatters.time.string(from: self)
    }

    var newdokHighlightDateTimeText: String {
        NewdokDateFormatters.highlightDateTime.string(from: self)
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
