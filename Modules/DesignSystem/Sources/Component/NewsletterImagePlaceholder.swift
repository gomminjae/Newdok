import SwiftUI

public struct NewsletterImagePlaceholder: View {
    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            Image(asset: DesignSystemAsset.emptyCase)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .accessibilityHidden(true)
    }
}
