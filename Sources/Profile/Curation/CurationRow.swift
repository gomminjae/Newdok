//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

struct CurationRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image("signup")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .padding(.leading, 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text("NEWNEEK")
                        .font(.hanSansNeo(16, .bold)) // 폰트 예시
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("매주 평일 아침")
                            .font(.hanSansNeo(14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("구독하기")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(Color.primaryNormal)
                        .frame(width: 91, height: 36)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#2866D3"), lineWidth: 1)
                        )
                        .padding(.trailing, 20)
                }
            }
            .padding(.top,0)
            .background(Color(hex: "#F7F7F7"))

            // 🔹 뉴스레터 소개글
            Text("세상 돌아가는 소식, 뉴닉으로!")
                .font(.hanSansNeo(14))
                .foregroundColor(.black)
                .padding(.leading, 20)
            
            // 🔹 태그 목록 (시사·상식 → 경제·시사 로 변경)
            HStack {
                TagView(text: "경제·시사")
                TagView(text: "비즈니스")
                TagView(text: "트렌드")
            }
            .padding(.leading, 20)
        }
        .frame(height: 186)
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
            .font(.hanSansNeo(12))
            .foregroundColor(Color(hex: "#363636"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
            )
    }
}

// 미리보기
#Preview {
    CurationRow()
}
