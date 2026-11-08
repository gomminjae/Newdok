import Foundation
import Observation
import SwiftUI
import Testing
import UIKit
@testable import Shared

@Suite("실제 SwiftUI 분석 표시 경계", .serialized)
@MainActor
struct AnalyticsViewTests {
    @Test(.timeLimit(.minutes(1)))
    func foregroundAndVisibility() async throws {
        let state = DisplayState()
        let recorder = DisplayRecorder()
        let window = host(DisplayFixture(state: state, recorder: recorder, navigation: false))
        defer { window.isHidden = true; window.rootViewController = nil }
        try await recorder.wait(for: .rootAppeared(1))
        try await recorder.wait(for: .eventCount(1))

        state.phase = .background
        state.revision = 1
        try await recorder.wait(for: .rendered(1))
        #expect(recorder.payloads.count == 1)

        state.phase = .active
        state.revision = 2
        try await recorder.wait(for: .eventCount(2))

        state.visible = false
        state.revision = 3
        try await recorder.wait(for: .rendered(3))
        #expect(recorder.payloads.count == 2)

        state.visible = true
        state.revision = 4
        try await recorder.wait(for: .eventCount(3))
        #expect(recorder.payloads.map(\.name) == Array(repeating: "content_state_viewed", count: 3))
        #expect(recorder.payloads.allSatisfy { $0.parameters["list_view_id"] == .string(state.list.id.uuidString.lowercased()) })
    }

    @Test(.timeLimit(.minutes(1)))
    func navigationDestinationDoesNotInheritHiddenRoot() async throws {
        let state = DisplayState()
        let recorder = DisplayRecorder()
        let window = host(DisplayFixture(state: state, recorder: recorder, navigation: true))
        defer { window.isHidden = true; window.rootViewController = nil }
        try await recorder.wait(for: .rootAppeared(1))
        try await recorder.wait(for: .eventCount(1))

        state.path = [1]
        try await recorder.wait(for: .eventCount(2))
        state.path = []
        try await recorder.wait(for: .eventCount(3))
        try await recorder.wait(for: .rootAppeared(2))

        #expect(recorder.payloads.map { $0.parameters["screen_name"] } == [.string("home"), .string("search"), .string("home")])
    }

    @Test(.timeLimit(.minutes(1)))
    func presentedContentKeepsItsOwnScreenScope() async throws {
        let state = DisplayState()
        let recorder = DisplayRecorder()
        let window = host(PresentedContentFixture(state: state, recorder: recorder))
        defer { window.isHidden = true; window.rootViewController = nil }
        try await recorder.wait(for: .rootAppeared(1))
        try await recorder.wait(for: .eventCount(1))
        state.contentPresented = true
        try await recorder.wait(for: .eventCount(2))
        state.contentPresented = false
        try await recorder.wait(for: .eventCount(3))
        try await recorder.wait(for: .presentedContentDisappeared)
        #expect(recorder.payloads.map { $0.parameters["screen_name"] } == [.string("home"), .string("subscribe_web"), .string("home")])
    }

    private func host(_ view: some View) -> UIWindow {
        let window: UIWindow
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            window = UIWindow(windowScene: scene)
        } else {
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        }
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }
}

@Observable
@MainActor
private final class DisplayState {
    var phase: ScenePhase = .active
    var visible = true
    var path: [Int] = []
    var revision = 0
    var contentPresented = false
    let list = AnalyticsListContext(.homeArticles)
}

// SharedTests has no application host. Mount presented content in the hosting
// tree to test visibility inheritance without relying on UIKit sheet presentation.
private struct PresentedContentFixture: View {
    @Bindable var state: DisplayState
    let recorder: DisplayRecorder

    var body: some View {
        Text("홈")
            .background(AppearanceProbe(onAppear: { recorder.rootAppeared() }))
            .analyticsScreen(.home, from: .home, isVisible: !state.contentPresented)
            .overlay {
                if state.contentPresented {
                    Text("구독 페이지")
                        .analyticsScreen(.subscribeWeb, from: .newsletterDetail)
                        .onDisappear { recorder.mark(.presentedContentDisappeared) }
                }
            }
            .analyticsVisibility(true)
            .environment(\.analyticsClient, recorder.client)
            .environment(\.scenePhase, .active)
    }
}

private struct DisplayFixture: View {
    @Bindable var state: DisplayState
    let recorder: DisplayRecorder
    let navigation: Bool

    var body: some View {
        Group {
            if navigation {
                NavigationStack(path: $state.path) {
                    Text("홈")
                        .background(AppearanceProbe(onAppear: { recorder.rootAppeared() }))
                        .analyticsScreen(.home, from: .home)
                        .analyticsVisibility(state.path.isEmpty)
                        .navigationDestination(for: Int.self) { route in
                            Text("검색")
                                .analyticsScreen(.search, from: .home)
                                .analyticsVisibility(state.path.last == route)
                        }
                }
            } else {
                Text("목록")
                    .background(AppearanceProbe(onAppear: { recorder.rootAppeared() }))
                    .analyticsContentState(.ready, list: state.list, date: .today)
            }
        }
        .analyticsVisibility(state.visible)
        .environment(\.analyticsClient, recorder.client)
        .environment(\.scenePhase, state.phase)
        .onChange(of: state.revision, initial: true) { _, value in recorder.mark(.rendered(value)) }
    }
}

@MainActor
private final class DisplayRecorder {
    enum Signal: Hashable, Sendable {
        case rendered(Int), eventCount(Int), rootAppeared(Int), presentedContentDisappeared
    }
    private(set) var payloads: [AnalyticsPayload] = []
    private var rootAppearances = 0
    private var received: Set<Signal> = []
    private var waiters: [Signal: CheckedContinuation<Void, Error>] = [:]

    var client: AnalyticsClient {
        AnalyticsClient { [self] event, source in
            guard let payload = event.payload(common: .init(environment: .development, build: "1", authState: .guest), from: source) else { return }
            payloads.append(payload)
            mark(.eventCount(payloads.count))
        }
    }

    func mark(_ signal: Signal) {
        received.insert(signal)
        waiters.removeValue(forKey: signal)?.resume()
    }

    func rootAppeared() {
        rootAppearances += 1
        mark(.rootAppeared(rootAppearances))
    }

    func wait(for signal: Signal) async throws {
        if received.contains(signal) { return }
        try await withTaskCancellationHandler {
            try Task.checkCancellation()
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                if Task.isCancelled { continuation.resume(throwing: CancellationError()) }
                else { waiters[signal] = continuation }
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.waiters.removeValue(forKey: signal)?.resume(throwing: CancellationError())
            }
        }
    }
}

private struct AppearanceProbe: UIViewControllerRepresentable {
    let onAppear: () -> Void

    func makeUIViewController(context: Context) -> Controller { Controller(onAppear: onAppear) }
    func updateUIViewController(_ uiViewController: Controller, context: Context) {}

    final class Controller: UIViewController {
        private let onAppear: () -> Void

        init(onAppear: @escaping () -> Void) {
            self.onAppear = onAppear
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { return nil }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            onAppear()
        }
    }
}
