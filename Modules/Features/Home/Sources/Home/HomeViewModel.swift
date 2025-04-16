//
//  HomeViewModel.swift
//  Home
//
//  Created by 권민재 on 4/16/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import Domain
import Core
import Shared




@MainActor
public final class HomeViewModel: ObservableObject {
    
    private let articleUseCase: ArticleUseCase
    
    public init(articleUseCase: ArticleUseCase) {
        self.articleUseCase = articleUseCase
    }
    
    
    @Published public var articles: [Article] = []
    
    @AppStorage("isGuest") public var isGuest: Bool = false
    
    
    
    
    
    
    
    
    
}
