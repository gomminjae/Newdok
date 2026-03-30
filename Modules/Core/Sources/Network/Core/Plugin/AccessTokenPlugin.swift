import Moya
import SwiftUI
import Shared

final class AuthPlugin: PluginType {
    private let tokenStorage: TokenStorable
    private let userInfoStore: UserInfoStorable
    private let authState: Authenticatable

    init(
        tokenStorage: TokenStorable,
        userInfoStore: UserInfoStorable,
        authState: Authenticatable
    ) {
        self.tokenStorage = tokenStorage
        self.userInfoStore = userInfoStore
        self.authState = authState
    }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request

        if let token = tokenStorage.accessToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        let statusCode: Int? = {
            switch result {
            case .success(let response):
                return response.statusCode
            case .failure(let error):
                if case let .statusCode(response) = error {
                    return response.statusCode
                }
                return nil
            }
        }()

        guard statusCode == 401 else { return }

        tokenStorage.clear()
        userInfoStore.clear()

        DispatchQueue.main.async { [authState] in
            authState.logout()
            NotificationCenter.default.post(name: .didReceiveUnauthorized, object: nil)
        }
    }
}
