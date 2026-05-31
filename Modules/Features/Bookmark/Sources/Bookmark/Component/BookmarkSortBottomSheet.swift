import SwiftUI
import DesignSystem
import BookmarkDomain

struct BookmarkSortBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var sortOrder: BookmarkSortOption
    var onSelect: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

            HStack {
                Text("정렬")
                    .font(.hanSansNeo(20, .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
                .accessibilityLabel("닫기")
                .accessibilityIdentifier("bookmark_sort_close_button")
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(BookmarkSortOption.allCases, id: \.self) { option in
                    Button(action: {
                        sortOrder = option
                        Task {
                            await onSelect()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 0) {
                            Text(option.displayText)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color.captionStrong)
                            Spacer()
                            if sortOrder == option {
                                Image(asset: DesignSystemAsset.lineCheckmark)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.primaryNormal)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                        .contentShape(Rectangle())
                    }
                    .accessibilityLabel("\(option.displayText)\(sortOrder == option ? ", 선택됨" : "")")
                    .accessibilityIdentifier("bookmark_sort_option_\(option.rawValue)")
                    .buttonStyle(.plain)

                    if option != BookmarkSortOption.allCases.last {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
            .padding(.top, 28)

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
}
