import SwiftUI

@MainActor
public protocol HomeBuildable {
    func makeHomeView() -> AnyView
}
