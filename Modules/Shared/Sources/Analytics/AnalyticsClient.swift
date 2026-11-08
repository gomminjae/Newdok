import SwiftUI

public struct AnalyticsClient: Sendable {
    private let emit: @MainActor @Sendable (AnalyticsEvent, AnalyticsEntryPoint) -> Void

    public init(record: @escaping @MainActor @Sendable (AnalyticsEvent, AnalyticsEntryPoint) -> Void) {
        emit = record
    }

    @MainActor
    public func record(_ event: AnalyticsEvent, from entryPoint: AnalyticsEntryPoint) {
        emit(event, entryPoint)
    }

    public static let disabled = Self { _, _ in }
}

private struct AnalyticsClientKey: EnvironmentKey {
    static let defaultValue: AnalyticsClient = .disabled
}

private struct AnalyticsVisibilityKey: EnvironmentKey {
    static let defaultValue = true
}

private struct AnalyticsVisibilityManagedKey: EnvironmentKey {
    static let defaultValue = false
}

private extension EnvironmentValues {
    var analyticsVisibilityIsManaged: Bool {
        get { self[AnalyticsVisibilityManagedKey.self] }
        set { self[AnalyticsVisibilityManagedKey.self] = newValue }
    }
}

public extension EnvironmentValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClientKey.self] }
        set { self[AnalyticsClientKey.self] = newValue }
    }

    var analyticsIsVisible: Bool {
        get { self[AnalyticsVisibilityKey.self] }
        set { self[AnalyticsVisibilityKey.self] = newValue }
    }
}

private struct AnalyticsVisibilityModifier: ViewModifier {
    @Environment(\.analyticsIsVisible) private var parentVisible
    let visible: Bool

    func body(content: Content) -> some View {
        content
            .environment(\.analyticsIsVisible, parentVisible && visible)
            .environment(\.analyticsVisibilityIsManaged, true)
    }
}

private struct AnalyticsScreenModifier: ViewModifier {
    @Environment(\.analyticsClient) private var client
    @Environment(\.analyticsIsVisible) private var scopeVisible
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.analyticsVisibilityIsManaged) private var visibilityIsManaged
    @State private var appeared = false
    @State private var lastScreen: ScreenKey?
    let key: ScreenKey
    let onRecorded: () -> Void
    let visible: Bool
    private var isPresented: Bool { appeared && scopeVisible && visible }

    struct ScreenKey: Hashable {
        let screen: AnalyticsScreen
        let step: AnalyticsStep?
        let flowID: UUID?
        let entryPoint: AnalyticsEntryPoint
    }

    func body(content: Content) -> some View {
        content
            .onAppear { appeared = true }
            // A scoped route/tab owns visibility. Delayed disappear callbacks from a
            // previous navigation transition must not reset the new visible visit.
            .onDisappear { if !visibilityIsManaged { appeared = false } }
            .onChange(of: key) { old, new in
                // Consuming the first-home flow link is bookkeeping, not another screen visit.
                if old.flowID != nil, new.flowID == nil, old.screen == new.screen, old.step == new.step {
                    lastScreen = new
                } else { track() }
            }
            .onChange(of: isPresented) { _, visible in
                if !visible { lastScreen = nil }
                track()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active { track() }
            }
    }

    private func track() {
        guard isPresented, scenePhase == .active, lastScreen != key else { return }
        lastScreen = key
        client.record(.screenViewed(key.screen, step: key.step, flowID: key.flowID), from: key.entryPoint)
        onRecorded()
    }
}

public extension View {
    func analyticsContentState(
        _ state: AnalyticsContentState?, list: AnalyticsListContext,
        date: AnalyticsDateRelation? = nil,
        isVisible: Bool = true
    ) -> some View {
        modifier(AnalyticsContentStateModifier(state: state, list: list, date: date, locallyVisible: isVisible))
    }

    func analyticsVisibility(_ visible: Bool) -> some View {
        modifier(AnalyticsVisibilityModifier(visible: visible))
    }

    func analyticsScreen(
        _ screen: AnalyticsScreen,
        from entryPoint: AnalyticsEntryPoint,
        step: AnalyticsStep? = nil,
        flowID: UUID? = nil,
        isVisible: Bool = true,
        onRecorded: @escaping () -> Void = {}
    ) -> some View {
        modifier(AnalyticsScreenModifier(key: .init(screen: screen, step: step, flowID: flowID, entryPoint: entryPoint), onRecorded: onRecorded, visible: isVisible))
    }
}

private struct AnalyticsContentStateModifier: ViewModifier {
    @Environment(\.analyticsClient) private var client
    @Environment(\.analyticsIsVisible) private var visible
    @Environment(\.scenePhase) private var phase
    @Environment(\.analyticsVisibilityIsManaged) private var visibilityIsManaged
    @State private var appeared = false
    @State private var lastKey: Key?
    let state: AnalyticsContentState?
    let list: AnalyticsListContext
    let date: AnalyticsDateRelation?
    let locallyVisible: Bool
    private var isPresented: Bool { appeared && visible && locallyVisible }

    private struct Key: Equatable {
        let state: AnalyticsContentState
        let list: AnalyticsListContext
        let date: AnalyticsDateRelation?
    }
    private var key: Key? { state.map { Key(state: $0, list: list, date: date) } }

    func body(content: Content) -> some View {
        content
            .onAppear { appeared = true }
            .onDisappear { if !visibilityIsManaged { appeared = false } }
            .onChange(of: key) { _, _ in track() }
            .onChange(of: isPresented) { _, value in
                if !value { lastKey = nil }
                track()
            }
            .onChange(of: phase) { _, newPhase in
                if newPhase != .active { lastKey = nil }
                track()
            }
    }

    private func track() {
        guard isPresented, phase == .active, let key, lastKey != key else { return }
        lastKey = key
        client.record(.contentStateViewed(surface: list.list.surface, state: key.state, list: list, date: date), from: list.list.entryPoint)
    }
}
