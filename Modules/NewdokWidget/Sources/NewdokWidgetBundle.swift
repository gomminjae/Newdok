import SwiftUI
import WidgetKit

@main
struct NewdokWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        ArticleLiveActivityWidget()
    }
}
