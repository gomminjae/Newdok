//
//  TokenStorage.swift
//  Shared
//
//  Created by 권민재 on 4/8/25.
//


import Foundation
import SwiftUI

public enum TokenStorage {
    @AppStorage("accessToken") public static var accessToken: String?
}
