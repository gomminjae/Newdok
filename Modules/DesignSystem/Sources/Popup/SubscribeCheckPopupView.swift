//
//  Untitled.swift
//  DesignSystem
//
//  Created by 권민재 on 8/3/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct SubscribeCheckPopupView: View {
    public let checkMail: () -> Void
    
    public init(checkMail: @escaping () -> Void) {
        self.checkMail = checkMail
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.grayMedium)
            
            Text("구독 확인 필요")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color.captionHeavy)
                .padding(.bottom, 6)
            
            Text("구독 신청을 완료하기 위해\n구독 확인 메일의 확인 버튼을 눌러주세요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionBody)
                .padding(.bottom, 24)
            
            Text("구독 확인 메일은 홈에서 확인할 수 있어요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color.primaryNormal)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.bgSecondary)
                .cornerRadius(6)
                .padding(.bottom, 24)
            
            Button(action: checkMail) {
                Text("메일 확인하기")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    SubscribeCheckPopupView(checkMail: {})
}
