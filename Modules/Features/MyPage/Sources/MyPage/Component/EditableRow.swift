import SwiftUI
import DesignSystem

struct EditableRow: View {
    let title: String
    let text: String
    var placeholder: String = ""
    var onEdit: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? Color.captionAssistive : Color.captionNeutral)
                    .font(.hanSansNeo(14, .medium))
                Spacer()
                Button(action: { onEdit?() }) {
                    Image(asset: DesignSystemAsset.lineEdit)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color.captionStrong)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding()
            .frame(height: 48)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.lineAlternative, lineWidth: 1)
            }
        }
    }
}
