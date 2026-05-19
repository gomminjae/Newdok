import Foundation

public protocol SaveReadArticleIdsUseCase: Sendable {
    func execute(_ ids: Set<Int>)
}
