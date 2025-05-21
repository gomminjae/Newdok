//
//  AppCoordinatorEntry.swift
//  AppCoordinator
//
//  Created by 권민재 on 4/5/25.
//
import SwiftUI
import Shared

public enum AppCoordinatorEntry {

    
    @MainActor
    public static func makeAFlow() -> some View {
       QABRootViewView()
            
    }
}


