import Combine

@MainActor
public protocol Authenticatable: AnyObject {
    var authState: AuthState { get }
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    func login()
    func logout()
}
