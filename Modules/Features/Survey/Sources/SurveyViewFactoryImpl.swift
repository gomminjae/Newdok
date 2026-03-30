import SwiftUI
import SurveyInterface

public struct SurveyViewFactoryImpl: SurveyViewFactory {
    public init() {}

    @MainActor public func makeSurveyView() -> AnyView {
        AnyView(EmptyView())
    }
}
