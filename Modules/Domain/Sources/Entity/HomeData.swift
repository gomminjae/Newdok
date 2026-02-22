//
//  HomeData.swift
//  Domain
//
//  Created by 권민재 on 4/19/25.
//
import Foundation

public struct HomeData {
    public let articles: [Article]
    public let activeNewsletters: [Newsletter]
    
    public init(articles: [Article], activeNewsletters: [Newsletter]) {
        self.articles = articles
        self.activeNewsletters = activeNewsletters
    }
}
