import SwiftUI
import DesignSystem
import Kingfisher
import DetailDomain

struct BrandHeroSection: View {
    let detail: DetailBrandDetail
    let isGuest: Bool
    let isMutating: Bool
    let displayScale: CGFloat
    let onSubscribeAction: (SubscriptionStatus) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            heroImage
            checkOverlay
            interestBadges
            bottomBar
        }
        .frame(height: 300)
    }

    private var heroImage: some View {
        Group {
            if let urlString = detail.imageUrl,
               let url = URL(string: urlString) {
                GeometryReader { geo in
                    KFImage(url)
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: geo.size.width * displayScale, height: geo.size.height * displayScale)))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            } else {
                Color.lineSoft
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .overlay(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.0),
                    .init(color: Color.black.opacity(0.06), location: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .mask(RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight]))
        .clipped()
        .shadow(
            color: Color(red: 0x19 / 255, green: 0x19 / 255, blue: 0x19 / 255).opacity(0.04),
            radius: 4, x: 0, y: 2
        )
    }

    @ViewBuilder
    private var checkOverlay: some View {
        if detail.subscriptionStatus == .check {
            Color.bgPopupDim.opacity(0.6)
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .mask(RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight]))
                .overlay(
                    Text("구독 확인 중")
                        .font(.hanSansNeo(16, .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
        }
    }

    private var interestBadges: some View {
        HStack(spacing: 4) {
            ForEach(detail.interests.prefix(3), id: \.id) { interest in
                Text(interest.name)
                    .font(.hanSansNeo(11, .medium))
                    .foregroundStyle(Color.captionStrong)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.bgNormal.opacity(0.61))
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(Color.lineNeutral, lineWidth: 1) }
            }

            Spacer()

            if detail.subscriptionStatus == .confirmed {
                Text("구독중")
                    .font(.hanSansNeo(11, .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 50, height: 26)
                    .background(Color.primaryLight)
                    .clipShape(Capsule())
                    .overlay { Capsule().stroke(Color.primaryNormal, lineWidth: 1) }
            }
        }
        .padding(.trailing, 16)
        .padding(.top, 12)
        .padding(.leading, 16)
    }

    private var bottomBar: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(detail.brandName)
                        .font(.hanSansNeo(16, .bold))
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineClock)
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.captionNeutral)
                            .frame(width: 20, height: 20)
                        Text(detail.publicationCycle)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color.captionNeutral)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                BrandSubscribeButton(
                    status: isGuest ? .initial : detail.subscriptionStatus,
                    isMutating: isMutating,
                    action: onSubscribeAction
                )
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            .padding(.bottom, 21)
            .background(Color.bgNormal.opacity(0.6))
            .background(VisualEffectBlur(blurStyle: .systemUltraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .offset(y: 20)
            .padding(.bottom, 12)
        }
    }
}
