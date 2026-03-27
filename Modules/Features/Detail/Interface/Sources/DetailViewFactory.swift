import SwiftUI

public protocol DetailViewFactory {
    @MainActor func makeBrandDetailView(id: String) -> AnyView
    @MainActor func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView
}
