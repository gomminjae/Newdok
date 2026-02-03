//
//  VersionCheckService.swift
//  App
//
//  Created by 권민재 on 2/3/26.
//

import Foundation
import UIKit

// MARK: - App Store Response Models
private struct AppStoreResponse: Codable {
    let resultCount: Int
    let results: [AppStoreResult]
}

private struct AppStoreResult: Codable {
    let version: String
}

// MARK: - VersionCheckService
final class VersionCheckService: Sendable {

    static let shared = VersionCheckService()

    private init() {}

    /// 앱 스토어에서 최신 버전을 확인하고 업데이트가 필요한지 체크
    /// - Returns: 업데이트가 필요하면 true, 아니면 false
    /// - Note: 현재 버전은 Project.swift의 MARKETING_VERSION에서 관리됨
    func checkForUpdate() async -> Bool {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else {
            return false
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(AppStoreResponse.self, from: data)

            guard let appStoreVersion = decodedResponse.results.first?.version,
                  // CFBundleShortVersionString = Tuist Project.swift의 MARKETING_VERSION
                  let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                return false
            }

            return appStoreVersion.compare(currentVersion, options: .numeric) == .orderedDescending
        } catch {
            print("Failed to check version: \(error)")
            return false
        }
    }

    /// 앱 스토어로 이동
    func openAppStore() {
        guard let bundleId = Bundle.main.bundleIdentifier,
              let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/\(bundleId)") else {
            return
        }

        Task { @MainActor in
            UIApplication.shared.open(url)
        }
    }
}
