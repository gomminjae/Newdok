//
//  NetworkLoggerPlugin.swift
//  Network
//
//  Created by 권민재 on 3/27/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Moya
import Foundation

final class NetworkLoggerPlugin: PluginType {
    private static let redactedValue = "<redacted>"

    func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        if let url = request.request?.url {
            print("➡️ [Request] \(target.method.rawValue) \(redactedURL(url))")
        } else {
            print("➡️ [Request] \(target.method.rawValue) \(target.path)")
        }

        if let headers = request.request?.allHTTPHeaderFields {
            print("🔸 Headers: \(redactedHeaders(headers))")
        }

        if let body = request.request?.httpBody {
            print("📦 Body: \(redactedBody(body))")
        }
        #endif
    }

    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            if let url = response.request?.url {
                print("✅ [Response] \(response.statusCode) \(redactedURL(url))")
            } else {
                print("✅ [Response] \(response.statusCode) \(target.path)")
            }

            if response.statusCode == 401 {
                print("⚠️ [Auth] 401 Unauthorized - 토큰 만료 또는 로그인 필요")
            }

            print("📥 Body: \(redactedBody(response.data))")

        case .failure(let error):
            print("❌ [Failure] \(target.path) - \(error.localizedDescription)")

            if let response = error.response {
                if let url = response.request?.url {
                    print("🔻 URL: \(redactedURL(url))")
                }
                print("🔻 Status Code: \(response.statusCode)")
                print("📥 Body: \(redactedBody(response.data))")
            }
        }
        #endif
    }

    private func redactedURL(_ url: URL) -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else { return url.absoluteString }

        components.queryItems = queryItems.map { item in
            URLQueryItem(
                name: item.name,
                value: Self.isSensitiveKey(item.name) ? Self.redactedValue : item.value
            )
        }
        return components.url?.absoluteString ?? url.absoluteString
    }

    private func redactedHeaders(_ headers: [String: String]) -> [String: String] {
        var redacted = headers
        for key in headers.keys where Self.isSensitiveHeader(key) {
            redacted[key] = Self.redactedValue
        }
        return redacted
    }

    private func redactedBody(_ data: Data) -> String {
        guard !data.isEmpty else { return "<empty>" }
        guard let json = try? JSONSerialization.jsonObject(with: data),
              JSONSerialization.isValidJSONObject(json),
              let redactedData = try? JSONSerialization.data(withJSONObject: redactedJSON(json)),
              let redactedString = String(data: redactedData, encoding: .utf8)
        else {
            return "<non-JSON body omitted: \(data.count) bytes>"
        }
        return redactedString
    }

    private func redactedJSON(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            var redacted: [String: Any] = [:]
            for (key, nestedValue) in dictionary {
                redacted[key] = Self.isSensitiveKey(key)
                    ? Self.redactedValue
                    : redactedJSON(nestedValue)
            }
            return redacted
        }

        if let array = value as? [Any] {
            return array.map(redactedJSON)
        }

        return value
    }

    private static func isSensitiveHeader(_ key: String) -> Bool {
        let normalized = normalize(key)
        return normalized == "authorization"
            || normalized == "cookie"
            || normalized == "setcookie"
            || normalized == "xapikey"
    }

    private static func isSensitiveKey(_ key: String) -> Bool {
        let normalized = normalize(key)
        return normalized.contains("token")
            || normalized == "authorization"
            || normalized == "authorizationcode"
            || normalized == "password"
            || normalized.contains("secret")
    }

    private static func normalize(_ key: String) -> String {
        key.lowercased().filter { $0.isLetter || $0.isNumber }
    }
}
