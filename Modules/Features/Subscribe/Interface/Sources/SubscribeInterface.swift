import SwiftUI

@MainActor
public protocol SubscribeBuildable {
    func makeSubscribeView() -> AnyView
}
