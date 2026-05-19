import Foundation

public protocol LoadReadArticleIdsUseCase: Sendable {
    func execute() -> Set<Int>
}
