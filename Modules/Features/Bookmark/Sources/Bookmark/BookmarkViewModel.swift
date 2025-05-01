//
//  BookmarkViewModel.swift
//  Bookmark
//
//  Created by 권민재 on 5/2/25.
//  Copyright © 2025 Newdok. All rights reserved.
//
import Foundation
import SwiftUI
import Domain


protocol BookmarkViewModelBindable {
    
    func fetchUserInterests() async -> [Interest]
    
}



@MainActor
public class BookmarkViewModel: ObservableObject {
    
    private let useCase: ArticleUseCase
    
    public init(useCase: ArticleUseCase) {
        self.useCase = useCase
    }
    
    
    
}
