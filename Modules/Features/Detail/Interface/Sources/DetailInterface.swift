import SwiftUI

@MainActor
public protocol DetailBuildable {
    func makeBrandDetailView(id: String) -> AnyView
    func makeArticleDetailView(id: String, isPastArticle: Bool) -> AnyView
}
