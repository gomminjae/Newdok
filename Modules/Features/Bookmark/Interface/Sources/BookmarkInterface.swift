import SwiftUI

@MainActor
public protocol BookmarkBuildable {
    func makeBookmarkView(
        onSearch: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onArticleTap: @escaping (String) -> Void
    ) -> AnyView
}
