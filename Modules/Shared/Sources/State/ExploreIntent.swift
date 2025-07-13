import Foundation
import Combine

public final class ExploreIntent: ObservableObject {
    @Published public var day: Int? = nil
    @Published public var selectedTab: Int? = nil
    @Published public var trigger: UUID = UUID()
    
    public init() {}
    
    public func reset() {
        day = nil
        selectedTab = nil
        trigger = UUID()
    }
}
