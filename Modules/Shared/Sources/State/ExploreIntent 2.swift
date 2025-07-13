//
//  ExploreIntent 2.swift
//  Shared
//
//  Created by 권민재 on 7/13/25.
//


import Foundation
import SwiftUI

public final class ExploreIntent: ObservableObject {
    @Published public var day: Int?
    @Published public var selectedTab: Int?
    @Published public var trigger: UUID = UUID()
    public init() {}
} 