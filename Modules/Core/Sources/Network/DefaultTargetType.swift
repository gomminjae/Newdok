import Moya
import Foundation

public protocol DefaultTargetType: TargetType {}

public extension DefaultTargetType {
    var headers: [String: String]? {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }

    var sampleData: Data {
        Data()
    }
}
