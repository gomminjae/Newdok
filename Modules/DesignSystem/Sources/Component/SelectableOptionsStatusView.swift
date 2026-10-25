import SwiftUI
import Shared

/// Selection screens share the same loading/error presentation, without turning
/// an unavailable catalog into an empty user profile or an empty dropdown.
public struct SelectableOptionsStatusView: View {
    private let state: SelectableOptionsLoadState
    private let onRetry: () async throws -> Void

    public init(state: SelectableOptionsLoadState, onRetry: @escaping () async throws -> Void) {
        self.state = state
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 12) {
            switch state {
            case .idle, .loading:
                ProgressView("선택 목록을 불러오는 중이에요")
            case .failed:
                Text("선택 목록을 불러오지 못했어요.")
                    .font(.hanSansNeo(14, .medium))
                Button {
                    // Failure is presented through loadState, not a separate popup.
                    Task { try? await onRetry() }
                } label: {
                    Text("다시 시도")
                        .font(.hanSansNeo(14, .bold))
                        .frame(minWidth: 100, minHeight: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("선택 목록 다시 불러오기")
            case .loaded:
                Text("선택 가능한 항목이 없습니다.")
                    .font(.hanSansNeo(14, .medium))
            }
        }
        .foregroundStyle(Color.captionNeutral)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}
