import Foundation

/// One external subscription attempt; callbacks from popups, retries and dismissal can repeat.
@MainActor
public final class SubscriptionAnalyticsSession {
    public let id = UUID()
    private let newsletter: AnalyticsNewsletter
    private let client: AnalyticsClient
    private let entryPoint: AnalyticsEntryPoint
    private var opened = false
    private var failed = false
    private var closed = false

    public init?(
        newsletter: AnalyticsNewsletter, url: String, client: AnalyticsClient,
        from entryPoint: AnalyticsEntryPoint, viewID: UUID? = nil,
        status: AnalyticsSubscriptionStatus
    ) {
        guard let identifier = Int(newsletter.id), identifier > 0,
              let parsedURL = URL(string: url), ["https", "http"].contains(parsedURL.scheme?.lowercased() ?? ""),
              parsedURL.host?.isEmpty == false,
              entryPoint == .signupCuration || (entryPoint == .newsletterDetail && viewID != nil),
              status == .initial || status == .unknown || status == .check else { return nil }
        self.newsletter = newsletter
        self.client = client
        self.entryPoint = entryPoint
        client.record(.subscribeStarted(newsletter, attemptID: id, viewID: viewID, status: status), from: entryPoint)
    }

    public func pageLoaded() {
        guard !opened, !closed else { return }
        opened = true
        client.record(.subscribePageOpened(newsletter, attemptID: id), from: entryPoint)
    }

    public func pageFailed(_ error: Error) {
        guard !failed, !opened, !closed, !(error is CancellationError), (error as? URLError)?.code != .cancelled else { return }
        failed = true
        client.record(.operationFailed(.subscribePage(newsletter, attemptID: id), category: .init(error: error)), from: entryPoint)
    }

    public func pageClosed() {
        guard !closed else { return }
        closed = true
        client.record(.subscribePageClosed(newsletter, attemptID: id), from: entryPoint)
    }
}
