//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem

struct CurationRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 12) {
                Image("signup")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("NEWNEEK")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(.black)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)

                        Text("매주 평일 아침")
                            .font(.hanSansNeo(13))
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                Button(action: {}) {
                    Text("구독하기")
                        .font(.hanSansNeo(13, .bold))
                        .foregroundStyle(Color(hex: "#2866D3"))
                        .frame(width: 80, height: 32)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#2866D3"), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color(hex: "#F7F7F7"))

            // 🔹 하단 흰 배경 영역
            VStack(alignment: .leading, spacing: 12) {
                Text("세상 돌아가는 소식, 뉴닉으로!")
                    .font(.hanSansNeo(14,.medium))
                    .foregroundStyle(Color(hex: "#363636"))

                HStack(spacing: 8) {
                    TagView(text: "시사·상식")
                    TagView(text: "비즈니스")
                    TagView(text: "트렌드")
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        )
    }
}

struct TagView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.hanSansNeo(12))
            .foregroundStyle(Color(hex: "#363636"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
            )
    }
}
#Preview {
    CurationRow()
}
