@MainActor
protocol HighlightRenderable: AnyObject {
    func send(_ command: HighlightCommand)
    var events: AsyncStream<HighlightEvent> { get }
}
