import Shared
import SwiftUI
import WidgetKit

struct TodayWidgetEntry: TimelineEntry {
    let date: Date
    let summary: WidgetHomeSummary
}

struct TodayWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayWidgetEntry {
        TodayWidgetEntry(date: Date(), summary: .empty())
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayWidgetEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayWidgetEntry>) -> Void) {
        let entry = makeEntry()
        let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(60 * 60 * 6)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func makeEntry() -> TodayWidgetEntry {
        let now = Date()
        let summary = loadSummary(for: now)
        return TodayWidgetEntry(date: now, summary: summary)
    }

    private func loadSummary(for date: Date) -> WidgetHomeSummary {
        guard let appGroupID = AppGroup.identifier,
              let store = AppGroupWidgetHomeSummaryStore(appGroupID: appGroupID),
              let summary = store.readWidgetHomeSummary(),
              Calendar.current.isDate(summary.date, inSameDayAs: date)
        else {
            return .empty(for: date)
        }
        return summary
    }
}

struct TodayWidget: Widget {
    let kind = WidgetKind.homeSummary

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayWidgetProvider()) { entry in
            TodayWidgetEntryView(summary: entry.summary)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(URL(string: "newdok://home"))
        }
        .configurationDisplayName("오늘의 뉴스레터")
        .description("오늘 도착한 뉴스레터와 미읽음 수를 보여줍니다.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

struct TodayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let summary: WidgetHomeSummary

    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            rectangularContent
        default:
            circularContent
        }
    }

    private var circularContent: some View {
        VStack(spacing: 1) {
            Image(systemName: "envelope.fill")
                .font(.caption2)
            Text("\(summary.unreadCount)")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.7)
        }
    }

    private var rectangularContent: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("오늘 도착 \(summary.todayTotalCount)개")
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            Text("미읽음 \(summary.unreadCount)개")
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

#Preview(as: .accessoryCircular) {
    TodayWidget()
} timeline: {
    TodayWidgetEntry(date: .now, summary: .empty())
    TodayWidgetEntry(
        date: .now,
        summary: WidgetHomeSummary(date: .now, todayTotalCount: 5, unreadCount: 2)
    )
}

#Preview(as: .accessoryRectangular) {
    TodayWidget()
} timeline: {
    TodayWidgetEntry(
        date: .now,
        summary: WidgetHomeSummary(date: .now, todayTotalCount: 12, unreadCount: 3)
    )
}
