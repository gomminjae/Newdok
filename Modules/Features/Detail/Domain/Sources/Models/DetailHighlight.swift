import Foundation

public struct DetailHighlight: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let articleId: String
    public let articleTitle: String
    public let brandName: String
    public let selectedText: String
    public let style: HighlightStyle
    public let textOffset: Int
    public let createdAt: Date

    public init(
        id: UUID,
        articleId: String,
        articleTitle: String,
        brandName: String,
        selectedText: String,
        style: HighlightStyle,
        textOffset: Int,
        createdAt: Date
    ) {
        self.id = id
        self.articleId = articleId
        self.articleTitle = articleTitle
        self.brandName = brandName
        self.selectedText = selectedText
        self.style = style
        self.textOffset = textOffset
        self.createdAt = createdAt
    }
}
