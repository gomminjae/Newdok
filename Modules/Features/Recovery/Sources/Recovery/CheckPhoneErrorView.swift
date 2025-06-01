//
//  CheckPhoneErrorView.swift
//  Recovery
//
//  Created by 권민재 on 6/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import SwiftUI
import DesignSystem


struct CheckPhoneErrorView: View {
    /// 닫기(X) 버튼, 회원가입 버튼 액션
    var onClose: () -> Void = {}
    var onSignUp: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(asset: DesignSystemAsset.lineClose)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#969696"))
                        .padding(20)
                }
            }

          
            VStack(spacing: 0) {
                Image(asset: DesignSystemAsset.warning)
                
         
                Text("가입되지 않은 휴대폰 번호입니다.")
                    .font(.hanSansNeo(20, .bold))
                    
                    .padding(.bottom, 6)
                
              
                Text("회원가입을 원하시면\n아래 버튼을 눌러주세요.")
                    .multilineTextAlignment(.center)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#565656"))
                    .padding(.bottom, 24)
                
              
                Button(action: onSignUp) {
                    Text("회원가입")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            .offset(y: -36)
        }
        //.frame(height: 280)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CheckPhoneErrorView()
}
