import Foundation
import NetworkKit
import DatabaseKit

@MainActor
final class AppDependencies {
    let networkProvider: NetworkProviding
    let highlightDataSource: HighlightLocalDataSource

    init(
        networkProvider: NetworkProviding = NetworkProvider(),
        highlightDataSource: HighlightLocalDataSource = DefaultHighlightLocalDataSource.shared
    ) {
        self.networkProvider = networkProvider
        self.highlightDataSource = highlightDataSource
    }
}
