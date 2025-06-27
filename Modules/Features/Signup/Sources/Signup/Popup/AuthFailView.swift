//
//  AuthFailView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem

struct AuthFailView: View {
    
    var onClose: () -> Void
    
    var body: some View {
        
            VStack(spacing: 0) {
                Image(asset: DesignSystemAsset.warning)
                    .padding(.top, 20)
                Text("인증에 실패하였습니다.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.top, 6)
                Text("인증 횟수를 초과했습니다.\n처음부터 다시 진행해주세요.")
                    .font(.hanSansNeo(14, .regular))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                Button("처음으로") {
                    onClose()
                }
                .font(.hanSansNeo(14,.bold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(Color.white)
                .background(Color(hex: "2866D3"))
                .cornerRadius(4)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top,  24)
                
            }
           
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    
        
}

#Preview {
    AuthFailView(onClose: {})
}
