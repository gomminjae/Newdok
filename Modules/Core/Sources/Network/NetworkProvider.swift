//
//  NetworkProvider.swift
//  Network
//
//  Created by 권민재 on 4/6/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import Moya
import Foundation
import Alamofire
import Shared

public protocol NetworkProviding {
    func makeAuthProvider() -> MoyaProvider<UserAPI>
    func makeArticleProvider() -> MoyaProvider<ArticleAPI>
    func makeNewsletterProvider() -> MoyaProvider<NewsletterAPI>
    func makeSearchProvider() -> MoyaProvider<SearchAPI>
}

public final class NetworkProvider: NetworkProviding {
    public init() {
    }
    
    private var plugins: [PluginType] {
        var pluginList: [PluginType] = [
            AuthPlugin()
        ]

        #if DEBUG
        pluginList.append(NetworkLoggerPlugin())
        #endif

        return pluginList
    }

    public func makeAuthProvider() -> MoyaProvider<UserAPI> {
        return MoyaProvider<UserAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }
    
    public func makeArticleProvider() -> MoyaProvider<ArticleAPI> {
        return MoyaProvider<ArticleAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }
    
    public func makeNewsletterProvider() -> MoyaProvider<NewsletterAPI> {
        return MoyaProvider<NewsletterAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }
    
    public func makeSearchProvider() -> MoyaProvider<SearchAPI> {
        return MoyaProvider<SearchAPI>(
            session: makeSafeSession(),
            plugins: plugins
        )
    }
    
    private func makeSafeSession() -> Session {
        #if targetEnvironment(simulator)
        let config = URLSessionConfiguration.ephemeral
        config.headers = .default
        #else
        let config = URLSessionConfiguration.default
        config.headers = .default
        #endif

        return Session(configuration: config)
    }
}
