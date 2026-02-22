//
//  CheckSubscribeView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/21/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct CheckSubscribeView: View {
    @Environment(\.dismiss) var dismiss
    
    public var onConfirmEmail: () -> Void = {}
    
    public init(onConfirmEmail: @escaping () -> Void = {}) {
          self.onConfirmEmail = onConfirmEmail
      }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    dismiss()  // 팝업 닫기
                }) {
                    Image(asset: DesignSystemAsset.lineClose)
                        .renderingMode(.template)
                        .foregroundColor(Color(hex: "#969696"))
                }
            }
            
            Image(asset: DesignSystemAsset.warning)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(Color(hex: "#C4C4C4"))

            Text("구독 확인 필요")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color(hex: "#161616"))
                .padding(.bottom, 8)

            Text("구독 신청을 완료하기 위해\n구 독 확인 메일의 확인 버튼을 눌러주세요.")
                .multilineTextAlignment(.center)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#555555"))
                .padding(.bottom, 20)

            Text("구독 확인 메일은 홈에서 확인할 수 있어요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(Color(hex: "#2866D3"))
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(6)
                .padding(.bottom, 24)

            HStack(spacing: 8) {
                Button(action: {
                    onConfirmEmail()
                    dismiss()
                }) {
                    Text("메일 확인하기")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.primaryNormal)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "#EBEBEB")))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CheckSubscribeView()
}
