//
//  Article.swift
//  Core
//
//  Created by 권민재 on 4/11/25.
//  Copyright ©LinePlus rights reserved.
//

import Moya
import Foundation

public enum ArticleAPI {
    case fetchArticles(year: String, publicationMonth: String)
    case fetchTodayArticle
    case fetchBookmarkArticles(interest: String)
    case changeBookmarkState(articleId: String)
    case fetchBookmarkedInterest
    case search(keyword: String)
    case fetchArticleDetail(id: String)
    
    
}

extension ArticleAPI: TargetType {
    public var baseURL: URL {
        return URL(string:
                    "\(APIEnvironment.development.baseURL)/aticles")!
    }
    
    public var path: String {
        switch self {
        case .fetchArticles:
            return ""
        case .fetchTodayArticle:
            return "/today"
        case .fetchBookmarkArticles:
            return "/bookmark"
        case .changeBookmarkState:
            return "/bookmark"
        case .fetchBookmarkedInterest:
            return "/bookmark/interest"
        case .search:
            return "/search"
        case .fetchArticleDetail(let id):
            return "/\(id)"
        
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .changeBookmarkState:
            return .post
        default:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .fetchArticles(let year, let month):
            return .requestParameters(parameters: [
                "year": year,
                "publicationMonth": month
            ], encoding: URLEncoding.default)
        case .fetchTodayArticle:
            return .requestPlain
        case .fetchBookmarkArticles(let interest):
            return .requestParameters(parameters: [
                "interest": interest
            ], encoding: URLEncoding.default)
        case .changeBookmarkState(let id):
            return .requestParameters(parameters: ["articleId": id], encoding: JSONEncoding.default)
        case .fetchBookmarkedInterest:
            return .requestPlain
        case .search(let word):
            return .requestParameters(parameters: ["ketword": word], encoding: URLEncoding.default)
        case .fetchArticleDetail:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    
}
