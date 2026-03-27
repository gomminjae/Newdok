import SwiftUI

public protocol BookmarkViewFactory {
    @MainActor func makeBookmarkView() -> AnyView
}
