import ActivityKit
import Foundation
import Shared
import SwiftUI
import UIKit
import WidgetKit

struct ArticleLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ArticleLiveActivityAttributes.self) { context in
            ArticleLiveActivityLockScreenView(
                attributes: context.attributes,
                imageData: context.state.imageData
            )
                .widgetURL(context.attributes.deepLinkURL)
                .activityBackgroundTint(.black)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    ArticleLiveActivityImage(data: context.state.imageData)
                        .frame(width: 30, height: 30)
                        .accessibilityLabel(context.attributes.brandName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.brandName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.articleTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
                ArticleLiveActivityImage(data: context.state.imageData)
                    .frame(width: 18, height: 18)
                    .accessibilityLabel(context.attributes.brandName)
            } compactTrailing: {
                Text(context.attributes.brandName)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 84, alignment: .leading)
                    .accessibilityLabel("\(context.attributes.brandName), \(context.attributes.articleTitle)")
            } minimal: {
                ArticleLiveActivityImage(data: context.state.imageData)
                    .frame(width: 18, height: 18)
                    .accessibilityLabel(context.attributes.brandName)
            }
            .widgetURL(context.attributes.deepLinkURL)
        }
    }
}

private struct ArticleLiveActivityLockScreenView: View {
    let attributes: ArticleLiveActivityAttributes
    let imageData: Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 10) {
                ArticleLiveActivityImage(data: imageData)
                    .frame(width: 40, height: 40)
                    .accessibilityLabel(attributes.brandName)

                VStack(alignment: .leading, spacing: 2) {
                    Text(attributes.brandName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(attributes.articleTitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(.white)
    }
}

private struct ArticleLiveActivityImage: View {
    let data: Data?

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "newspaper.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
