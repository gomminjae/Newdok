import SwiftUI

@MainActor
public protocol ExploreBuildable {
    func makeExploreView() -> AnyView
    func loadOptions() async throws
}
