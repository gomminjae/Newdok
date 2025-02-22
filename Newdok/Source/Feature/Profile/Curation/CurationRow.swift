//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

struct CurationRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // 🔹 뉴스레터 로고
                Image("signup")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.leading, 20)

                // 🔹 뉴스레터 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEWNEEK")
                        .font(.system(size: 16, weight: .bold))

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        Text("매주 평일 아침")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                

                Spacer()

                // 🔹 구독 버튼
                Button(action: {}) {
                    Text("구독하기")
                        .font(.hanSansNeo(14,.bold))
                        .foregroundStyle(.white)
                        .frame(width: 91, height: 36)
                        .background(Color.primaryNormal)
                        .cornerRadius(8)
                        .padding(.trailing, 20)
                }
            }

            // 🔹 뉴스레터 소개글
            Text("세상 돌아가는 소식, 뉴닉으로!")
                .font(.system(size: 14))
                .foregroundColor(.black)
                .padding(.leading, 20)
            
           
           

            // 🔹 태그 목록
            HStack {
                TagView(text: "시사·상식")
                TagView(text: "비즈니스")
                TagView(text: "트렌드")
            }
            .padding(.leading, 20)
        }
        .padding(.vertical,16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "EBEBEB"), lineWidth: 1) 
        )
    }
}


struct TagView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
            .foregroundColor(Color.primaryNormal)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primaryNormal, lineWidth: 1)
            )
            .background(Color(hex: "ECF3FF"))
    }
}

#Preview {
    CurationRow()
}
