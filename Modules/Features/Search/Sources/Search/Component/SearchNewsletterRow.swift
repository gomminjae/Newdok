import SwiftUI
import SearchDomain
import DesignSystem
import Kingfisher

struct SearchNewsletterRow: View {
    let result: SearchedNewsletter
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: result.imageUrl))
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 56 * displayScale, height: 56 * displayScale)))
                .placeholder {
                    Color.gray.opacity(0.2)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.lineNeutral, lineWidth: 1)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(result.brandName)
                    .font(.hanSansNeo(14, .bold))
                    .foregroundStyle(Color.captionTitle)
                Text(result.firstDescription)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionStrong)
            }
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.brandName), \(result.firstDescription)")
    }
}
