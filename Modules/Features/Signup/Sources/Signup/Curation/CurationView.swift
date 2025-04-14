//
//  CurationView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem

struct CurationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("닉네임님을 위한\n맞춤형 뉴스레터가 도착했어요!")
                .font(.hanSansNeo(20,.bold))
                .padding(.top, 24)
            Text("구독한 뉴스레터는 발행일에 맞춰 홈으로 배달해드려요.\n구독하기를 누르면 구독 이메일이 자동으로 복사돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 8)
            ScrollView {
                VStack(spacing: 12) {
                    CurationRow()
                    CurationRow()
                    CurationRow()
                    CurationRow()
                    CurationRow()
                    CurationRow()
                }
            }
            .padding(.top, 32)
            .scrollIndicators(.hidden)
            
            Button("메인으로") {
                print("text")
            }
            .font(.hanSansNeo(14, .bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.primaryNormal)
            .cornerRadius(4)
            .padding(.bottom, 16)
           
            
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    CurationView()
}
