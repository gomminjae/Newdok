//
//  EmailInfoModalView.swift
//  DesignSystem
//
//  Created by 권민재 on 8/9/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//
import SwiftUI

public struct EmailInfoModalView: View {
    
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    
    public var body: some View {
   
            VStack(alignment: .leading, spacing: 0) {
                
              
                Text("구독 이메일")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundStyle(Color(hex: "#161616"))
                    .padding(.top, 24)
                    .padding(.leading, 20)
                
                
                Text("회원가입 시 자동으로 생성되는\n뉴스레터 구독을 위한 이메일 주소예요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#161616"))
                    .padding(.top, 8)
                    .padding(.leading, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("""
                        뉴독으로 아티클을 받아보기 위해선
                        뉴독의 구독 이메일 주소로 구독을 신청해야 해요.
                        구독 이메일은 개인적인 용도로 사용하거나
                        메일을 보내는 것이 불가능해요.
                        """)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(Color(hex: "#2866D3"))
                        .multilineTextAlignment(.leading)
                        .padding(16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#F5F5F5"))
                .cornerRadius(6)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 16)


                
               
                    
                Button(action: {
                    isPresented = false
                }) {
                    Text("확인")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color(hex: "#2866D3"))
                        .cornerRadius(4)
                }
                .padding(.leading, 20)
                .padding(.trailing, 24)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.horizontal, 24)
        }
}

