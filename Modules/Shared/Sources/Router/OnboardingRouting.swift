//
//  OnboardingRouting.swift
//  Shared
//
//  Created by 권민재 on 4/5/25.
//

import Combine

public protocol OnboardingRouting: ObservableObject {
    var onboardingRoute: OnboardingRoute { get set }
}
