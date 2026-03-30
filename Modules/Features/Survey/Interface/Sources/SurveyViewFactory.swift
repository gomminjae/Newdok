import SwiftUI

public protocol SurveyViewFactory {
    @MainActor func makeSurveyView() -> AnyView
}
