import SwiftUI
import WidgetKit

@main
struct MeldeWidgetsBundle: WidgetBundle {
    var body: some Widget {
        MeldoTodayWidget()
        MeldenControl()
        LessonLiveActivity()
    }
}
