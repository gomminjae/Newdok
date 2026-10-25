import Shared

enum ExploreOptionsTestError: Error { case failed }

@MainActor
final class ExploreOptionsFetcher: FetchSelectableOptionsUseCase {
    private var result: Result<SelectableOptions, Error>
    private(set) var executeCallCount = 0

    init(result: Result<SelectableOptions, Error>) { self.result = result }

    func execute() async throws -> SelectableOptions {
        executeCallCount += 1
        return try result.get()
    }

    func setResult(_ result: Result<SelectableOptions, Error>) { self.result = result }
}
