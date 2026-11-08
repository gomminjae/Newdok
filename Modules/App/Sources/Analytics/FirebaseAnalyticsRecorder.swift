import Foundation
import FirebaseAnalytics
import FirebaseCore
import Shared

@MainActor
final class FirebaseAnalyticsRecorder {
    private let appState: AppState
    private let enabled: Bool
    private let build: String

    init(appState: AppState) {
        self.appState = appState
        build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unknown"
        // The checked-in Firebase resource belongs to production. Never send the
        // development app's automatic or custom events to that project.
        #if DEBUG
        enabled = false
        #else
        enabled = Bundle.main.bundleIdentifier == "com.newdok.app"
            && FirebaseApp.app()?.options.bundleID == Bundle.main.bundleIdentifier
        #endif
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }

    var client: AnalyticsClient {
        AnalyticsClient { [self] event, entryPoint in
            guard enabled else { return }
            let auth: AnalyticsAuthState = appState.authState == .authenticated ? .authenticated : .guest
            let common = AnalyticsCommonProperties(environment: .production, build: build, authState: auth)
            guard let payload = event.payload(common: common, from: entryPoint) else { return }
            let parameters: [String: Any] = payload.parameters.mapValues { value in
                switch value {
                case .string(let text): text
                case .integer(let number): number
                }
            }
            Analytics.logEvent(payload.name, parameters: parameters)
        }
    }
}
