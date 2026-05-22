import SwiftUI

@MainActor
public protocol SearchBuildable {
    func makeSearchView() -> AnyView
}
