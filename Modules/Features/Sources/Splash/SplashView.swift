//
//  SplashView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

public struct SplashView: View {
    public init() {}
    public var body: some View {
        VStack {
            Spacer()
            Image("logo")
            Spacer()
        }
    }
}

#Preview {
    SplashView()
}
