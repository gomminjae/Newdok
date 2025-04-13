//
//  EmailInfoView.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//
import SwiftUI

struct EmailInfoModalView: View {
    var body: some View {
        ZStack {
           
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
   
            VStack(alignment: .leading, spacing: 0) {
                
              
                Text("구독 이메일")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 24)
                    .padding(.horizontal, 24)
                
                
                Text("회원가입 시 자동으로 생성되는\n뉴스레터 구독을 위한 이메일 주소예요.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
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
                .padding(.horizontal, 20)
                .padding(.top, 16)


                
                HStack(spacing: 8) {
                    
                    Button(action: {
                        
                    }) {
                        Text("취소")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(Color(hex: "#565656"))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
                                  
                                
                                    
                            }
                           
                    }
                    
                    
                    Button(action: {
                        
                    }) {
                        Text("확인")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color(hex: "#2866D3"))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    EmailInfoModalView()
}
