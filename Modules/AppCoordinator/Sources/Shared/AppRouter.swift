//
//  AppRouter.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import Foundation
import SwiftUI


public final class AppRouter: ObservableObject {
    @Published public var route: AppRoute
    
    public init(initial: AppRoute = .splash) {
        self.route = initial
    }
}
