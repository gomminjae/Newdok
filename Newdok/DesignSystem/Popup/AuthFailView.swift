//
//  AuthFailView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct AuthFailView: View {
    
    var onClose: () -> Void
    var onLogin: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            VStack {
                Image("warning")
                    .padding(.top, 20)
                Text("인증에 실패하였습니다.")
                    .font(.hanSansNeo(18, .bold))
                Text("인증 횟수를 초과했습니다.\n처음부터 다시 진행해주세요.")
                    .font(.hanSansNeo(14, .regular))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                Button("처음으로") {
                    print("Hello")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(Color.white)
                .background(Color(hex: "2866D3"))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .padding(.top,  20)
                
            }
           
            .background(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
    
        
}

#Preview {
    AuthFailView(onClose: {}, onLogin: {})
}
