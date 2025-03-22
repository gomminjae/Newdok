//
//  SubscribeNoticeView.swift
//  Newdok
//
//  Created by 권민재 on 2/22/25.
//

import SwiftUI

struct SubscribeNoticeView: View {
    var onClose: () -> Void

    var body: some View {
        ZStack {
        
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { onClose() }

           
            VStack(alignment: .leading, spacing: 12) {
             
                Text("구독이메일")
                    .font(.hanSansNeo(16, .medium))

               
                Text("회원가입 시 자동으로 생성되는\n뉴스레터 구독을 위한 이메일 주소예요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "555555"))

               
                VStack(alignment: .leading) {
                    Text("뉴독으로 아티클을 받아보기 위해선\n뉴독의 구독 이메일 주소로 구독을 신청해야 해요.\n구독 이메일은 개인적인 용도로 사용하거나\n메일을 보내는 것이 불가능해요.")
                        .font(.hanSansNeo(12, .regular))
                        .foregroundStyle(Color.primaryNormal)
                        .multilineTextAlignment(.leading)
                }
                
                .padding(.vertical, 12)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(4)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
             
                Button("확인") {
                    print("확인")
                }
                .font(.hanSansNeo(14, .bold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.primaryNormal)
                .cornerRadius(12)
                .padding(.top, 18)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)
            .frame(maxWidth: 500, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SubscribeNoticeView(onClose: {})
}
