// periphery:ignore:all
// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
#if hasFeature(InternalImportsByDefault)
public import Foundation
#else
import Foundation
#endif
// MARK: - Swift Bundle Accessor for Static Frameworks
extension Foundation.Bundle {
/// Since Detail is a static framework, a cut down framework is embedded, with all the resources but only a stub Mach-O image.
    static let module: Bundle = {
        class BundleFinder {}
        let hostBundle = Bundle(for: BundleFinder.self)
        var candidates: [URL?] = [
            hostBundle.privateFrameworksURL,
            hostBundle.bundleURL.appendingPathComponent("Frameworks"),
            hostBundle.bundleURL,
            hostBundle.bundleURL.deletingLastPathComponent(),
            hostBundle.resourceURL,
            Bundle.main.privateFrameworksURL,
            Bundle.main.bundleURL.appendingPathComponent("Frameworks"),
            Bundle.main.bundleURL,
            Bundle.main.resourceURL,
            // App extensions are placed under PlugIns/ in the host app bundle.
            // Navigate up from the extension to the containing app's Frameworks directory.
            hostBundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Frameworks"),
        ].map({ $0?.appendingPathComponent("Detail.framework") })

        for candidate in candidates {
            if let bundle = candidate.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        var bundleCandidates: [URL?] = [
            hostBundle.resourceURL,
            hostBundle.bundleURL,
            hostBundle.privateFrameworksURL,
            hostBundle.bundleURL.appendingPathComponent("Frameworks"),
            hostBundle.bundleURL.deletingLastPathComponent(),
            Bundle.main.resourceURL,
            Bundle.main.bundleURL,
            Bundle.main.privateFrameworksURL,
            Bundle.main.bundleURL.appendingPathComponent("Frameworks"),
            hostBundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("Frameworks"),
        ]
        if ProcessInfo.processInfo.processName == "xctest"
            || ProcessInfo.processInfo.processName == "swift-testing"
        {
            bundleCandidates.append(hostBundle.bundleURL.appendingPathComponent(".."))
        }

        for candidate in bundleCandidates {
            let bundlePath = candidate?.appendingPathComponent("Detail_Detail.bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        return Bundle.main
    }()
}
// MARK: - Objective-C Bundle Accessor
@objc
public final class DetailResources: NSObject {
@objc public class var bundle: Bundle {
    return .module
}
}
// swiftformat:enable all
// swiftlint:enable all