import SwiftUI

@MainActor
public protocol BookmarkBuildable {
    func makeBookmarkView() -> AnyView
}
