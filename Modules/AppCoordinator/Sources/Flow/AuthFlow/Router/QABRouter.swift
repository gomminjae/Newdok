//
//  QABRouter.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//

import SwiftUI
import Shared

public final class QABRouter: ObservableObject, OnboardingRouting {
    @Published public var onboardingRoute: OnboardingRoute = .launch
}
