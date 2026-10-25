import Foundation
import NetworkKit
import Shared

struct FetchSelectableOptionsUseCaseImpl: FetchSelectableOptionsUseCase {
    let network: any NetworkService

    func execute() async throws -> SelectableOptions {
        guard let url = URL(string: "\(APIEnvironment.baseURL)/options") else {
            throw URLError(.badURL)
        }
        let response = try await network.request(FetchSelectableOptions(baseURL: url))
        return SelectableOptions(
            interests: response.interests,
            industries: response.industries,
            days: response.days
        )
    }
}

private struct FetchSelectableOptions: APIRequest {
    typealias Response = SelectableOptionsResponse

    let baseURL: URL
    var path: String { "" }
    var method: HTTPMethod { .get }
    var task: RequestTask { .plain }
}

private struct SelectableOptionsResponse: Decodable, Sendable {
    let interests: [SelectableItem]
    let industries: [SelectableItem]
    let days: [SelectableItem]
}
