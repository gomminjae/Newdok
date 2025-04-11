//
//  NewsletterAPI.swift
//  Newdok
//
//  Created by 권민재 on 3/4/25.
//

import Moya
import Foundation


enum NewsletterAPI {
    
    
    
    
    
}

extension NewsletterAPI: TargetType {
    var baseURL: URL {
        return URL(string:
                    "\(APIEnvironment.development.baseURL)/newsletters")!
    }
    
    
    
  
    
    
}
