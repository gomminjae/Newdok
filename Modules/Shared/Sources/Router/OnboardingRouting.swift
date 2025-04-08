//
//  OnboardingRouting.swift
//  Shared
//
//  Created by 권민재 on 4/5/25.
//

import Combine
import SwiftUI

public protocol OnboardingRouting: ObservableObject {
    var path: NavigationPath { get set }
    
    func push(_ route: OnboardingRoute)
    func pop()
    func reset()
}

