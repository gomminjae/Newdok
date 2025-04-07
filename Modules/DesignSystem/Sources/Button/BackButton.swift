//
//  BackButton.swift
//  DesignSystem
//
//  Created by 권민재 on 4/6/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI

public struct BackButton: View {
    @Environment(\.presentationMode) private var presentationMode

    public var useRouter: Bool
    public var routerPop: (() -> Void)?

    // MARK: - Init
    public init(useRouter: Bool = false, routerPop: (() -> Void)? = nil) {
        self.useRouter = useRouter
        self.routerPop = routerPop
    }

    public var body: some View {
        Button(action: {
            if useRouter {
                routerPop?()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(spacing: 4) {
                Image(asset: DesignSystemAsset.back)
               
            }
            .padding(.horizontal, 4)
        }
    }
}
