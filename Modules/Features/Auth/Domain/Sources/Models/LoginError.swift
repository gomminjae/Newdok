public enum LoginError: Error {
    case invalidPassword
    case accountNotFound
    case networkError(Error)
}
