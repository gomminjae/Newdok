import Shared
import SwiftUI
import WidgetKit

struct TodayArrivalEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct TodayArrivalProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayArrivalEntry {
        TodayArrivalEntry(date: Date(), count: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayArrivalEntry) -> Void) {
        completion(TodayArrivalEntry(date: Date(), count: loadCount()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayArrivalEntry>) -> Void) {
        let entry = TodayArrivalEntry(date: Date(), count: loadCount())
        let nextMidnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(60 * 60 * 6)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func loadCount() -> Int {
        AppGroupTodayArrivalCountStorage(appGroupID: AppGroup.identifier)?.todayArrivalCount ?? 0
    }
}

struct TodayArrivalWidget: Widget {
    let kind: String = WidgetKind.todayArrival

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayArrivalProvider()) { entry in
            TodayArrivalEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(URL(string: "newdok://home"))
        }
        .configurationDisplayName("오늘의 뉴스레터")
        .description("오늘 도착한 뉴스레터 개수를 보여줍니다.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct TodayArrivalEntryView: View {
    let entry: TodayArrivalEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "envelope.fill")
                    .font(.caption2)
                Text(displayText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .minimumScaleFactor(0.7)
            }
        }
    }

    private var displayText: String {
        entry.count > 0 ? "\(entry.count)" : "—"
    }
}

#Preview(as: .accessoryCircular) {
    TodayArrivalWidget()
} timeline: {
    TodayArrivalEntry(date: .now, count: 0)
    TodayArrivalEntry(date: .now, count: 3)
    TodayArrivalEntry(date: .now, count: 12)
}
