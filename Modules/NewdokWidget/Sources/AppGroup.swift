import Foundation

enum AppGroup {
    static var identifier: String {
        Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_ID") as? String
            ?? "group.com.newdok.app"
    }
}
