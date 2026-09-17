import ActivityKit
import DetailDomain
import Foundation
import OSLog
import Shared
import UIKit

private let articleLiveActivityLogger = Logger(subsystem: "com.newdok.app", category: "LiveActivity")

@MainActor
final class ArticleLiveActivityPublisher: ArticleActivityPublishing {
    private let staleInterval: TimeInterval = 4 * 60 * 60
    private var currentArticleID: String?
    private var requestID = UUID()
    private var endingActivityIDs: Set<String> = []

    func selectArticle(_ articleID: String?) {
        currentArticleID = articleID
        requestID = UUID()
        let obsoleteIDs = Set(Activity<ArticleLiveActivityAttributes>.activities.filter {
            $0.attributes.articleId != articleID && !endingActivityIDs.contains($0.id)
        }.map(\.id))
        endingActivityIDs.formUnion(obsoleteIDs)
        // 화면의 task 취소와 관계없이 이미 선택에서 벗어난 활동을 종료한다.
        Task {
            for activity in Activity<ArticleLiveActivityAttributes>.activities where obsoleteIDs.contains(activity.id) {
                let id = activity.id
                await activity.end(nil, dismissalPolicy: .immediate)
                endingActivityIDs.remove(id)
            }
        }
    }

    func startArticleActivity(
        articleId: String,
        brandName: String,
        articleTitle: String,
        brandImageURL: String?,
        isPastArticle: Bool
    ) async {
        guard currentArticleID == articleId, !Task.isCancelled else { return }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            articleLiveActivityLogger.error("Live Activities are disabled")
            return
        }

        let thisRequestID = UUID()
        requestID = thisRequestID

        let attributes = ArticleLiveActivityAttributes(
            articleId: articleId,
            brandName: brandName,
            articleTitle: articleTitle,
            isPastArticle: isPastArticle
        )
        let staleDate = Date().addingTimeInterval(staleInterval)
        guard Self.fitsPayload(attributes: attributes, imageData: nil) else {
            articleLiveActivityLogger.error("Article Live Activity metadata exceeds payload limit")
            return
        }
        var activeActivity: Activity<ArticleLiveActivityAttributes>?

        for activity in Activity<ArticleLiveActivityAttributes>.activities {
            guard isCurrentRequest(thisRequestID, articleID: articleId) else { return }
            guard !endingActivityIDs.contains(activity.id) else { continue }
            if activity.attributes == attributes,
               activity.activityState == .active || activity.activityState == .stale,
               activeActivity == nil {
                activeActivity = activity
                let imageData = activity.content.state.imageData
                let content = makeContent(
                    imageData: Self.fitsPayload(attributes: attributes, imageData: imageData) ? imageData : nil,
                    staleDate: staleDate
                )
                await activity.update(content)
            } else {
                let id = activity.id
                endingActivityIDs.insert(id)
                await activity.end(nil, dismissalPolicy: .immediate)
                endingActivityIDs.remove(id)
            }
        }

        guard isCurrentRequest(thisRequestID, articleID: articleId) else { return }
        if activeActivity == nil {
            do {
                articleLiveActivityLogger.debug("Requesting article Live Activity")
                activeActivity = try Activity.request(
                    attributes: attributes,
                    content: makeContent(imageData: nil, staleDate: staleDate)
                )
                articleLiveActivityLogger.notice("Article Live Activity started")
            } catch {
                // Live Activity는 보조 UI이므로 시작 실패가 아티클 열기를 막지 않는다.
                articleLiveActivityLogger.error("Article Live Activity request failed: \(error.localizedDescription, privacy: .public)")
                return
            }
        }

        guard let activeActivity,
              activeActivity.content.state.imageData == nil,
              let imageURL = Self.validatedImageURL(from: brandImageURL),
              let imageData = await Self.thumbnailData(from: imageURL, attributes: attributes),
              isCurrentRequest(thisRequestID, articleID: articleId),
              activeActivity.activityState == .active || activeActivity.activityState == .stale else {
            return
        }

        await activeActivity.update(makeContent(imageData: imageData, staleDate: staleDate))
    }

    func endArticleActivities() async {
        currentArticleID = nil
        requestID = UUID()
        endingActivityIDs.formUnion(Activity<ArticleLiveActivityAttributes>.activities.map(\.id))
        for activity in Activity<ArticleLiveActivityAttributes>.activities {
            let id = activity.id
            await activity.end(nil, dismissalPolicy: .immediate)
            endingActivityIDs.remove(id)
        }
    }

    private func isCurrentRequest(_ id: UUID, articleID: String) -> Bool {
        !Task.isCancelled && requestID == id && currentArticleID == articleID
    }

    private static func validatedImageURL(from value: String?) -> URL? {
        guard let value,
              let url = URL(string: value),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil else {
            return nil
        }
        return url
    }

    private func makeContent(imageData: Data?, staleDate: Date) -> ActivityContent<ArticleLiveActivityAttributes.ContentState> {
        ActivityContent(
            state: ArticleLiveActivityAttributes.ContentState(status: .reading, imageData: imageData),
            staleDate: staleDate
        )
    }

    private static func thumbnailData(from url: URL, attributes: ArticleLiveActivityAttributes) async -> Data? {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else {
                return nil
            }
            guard !Task.isCancelled else { return nil }
            return makeThumbnailData(from: data, attributes: attributes)
        } catch {
            return nil
        }
    }

    private static func makeThumbnailData(from data: Data, attributes: ArticleLiveActivityAttributes) -> Data? {
        guard let image = UIImage(data: data), image.size.width > 0, image.size.height > 0 else {
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        for side in [64.0, 48.0, 32.0, 24.0] {
            let targetSize = CGSize(width: side, height: side)
            let thumbnail = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
                UIColor.white.setFill()
                UIRectFill(CGRect(origin: .zero, size: targetSize))
                let scale = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
                let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                let origin = CGPoint(
                    x: (targetSize.width - drawSize.width) / 2,
                    y: (targetSize.height - drawSize.height) / 2
                )
                image.draw(in: CGRect(origin: origin, size: drawSize))
            }
            for quality in [0.7, 0.5, 0.3] {
                if let data = thumbnail.jpegData(compressionQuality: quality),
                   fitsPayload(attributes: attributes, imageData: data) {
                    return data
                }
            }
        }
        return nil
    }

    private static func fitsPayload(attributes: ArticleLiveActivityAttributes, imageData: Data?) -> Bool {
        let encoder = JSONEncoder()
        guard let metadata = try? encoder.encode(attributes),
              let state = try? encoder.encode(ArticleLiveActivityAttributes.ContentState(imageData: imageData)) else {
            return false
        }
        // Data의 Base64 팽창과 메타데이터까지 합산하고 시스템 인코딩 여유를 둔다.
        return metadata.count + state.count < 3_500
    }
}
