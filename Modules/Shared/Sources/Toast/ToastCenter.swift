import SwiftUI
import Observation

@Observable
@MainActor
public final class ToastCenter {
    public static let shared = ToastCenter()

    public private(set) var isShown: Bool = false
    public private(set) var message: String = ""

    private var dismissTask: Task<Void, Never>?

    public func show(_ message: String, duration: TimeInterval = 2.0) {
        dismissTask?.cancel()
        self.message = message
        self.isShown = true

        dismissTask = Task { [weak self] in
            do { try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000)) } catch { return }
            guard let self, !Task.isCancelled else { return }
            self.isShown = false
        }
    }

    public func hide() {
        dismissTask?.cancel()
        isShown = false
    }
}

// [ADDED] 전역 토스트 렌더러: 루트에서 overlay로 한 번만 붙임
public struct ToastHost: View {
    @Environment(ToastCenter.self) private var toast

    public init() {}

    public var body: some View {
        VStack {
            if toast.isShown {
                // DesignSystem의 ToastView는 상위 모듈에 존재하므로, 여기서는 텍스트만 렌더합니다.
                // 실제 디자인 토스트를 쓰려면 이 ToastHost를 App 레이어로 옮겨 DesignSystem을 import 하세요.Thread 1: Fatal error: No ObservableObject
                Text(toast.message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 10)
            }
            Spacer()
        }
        .animation(.easeInOut, value: toast.isShown)
    }
}
