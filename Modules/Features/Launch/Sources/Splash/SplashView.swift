//
//  SplashView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem

public struct SplashView: View {
    public init() {}
    public var body: some View {
        VStack {
            Image(asset: DesignSystemAsset.splash)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
