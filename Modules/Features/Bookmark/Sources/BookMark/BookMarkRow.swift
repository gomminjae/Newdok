//
//  BookMarkRow.swift
//  Newdok
//
//  Created by 권민재 on 3/2/25.
//

import SwiftUI

struct BookMarkRow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🦔 정부24 먹통 사건의 전말.txt")
                .font(.hanSansNeo(16,.medium))
                .lineLimit(1)
            
            Text("오늘의 뉴닉 지난 주말 일어난 행정복지센터·정부24 서비스 먹통 사태, 대체 무슨 일인지 살펴봤고 재건축 규제완화 등 주요 이슈를 정리해봤어요.")
                .font(.hanSansNeo(14,.regular))
                .foregroundColor(.gray)
                
                .lineLimit(2)
            
            HStack {
                Image("signup")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .background(.red)
                    .clipShape(Circle())
                
                Text("주간 컴퍼니타임스")
                    .font(.hanSansNeo(14,.medium))
                    .bold()
                
                Spacer()
                
                Text("2023-11-26")
                    .font(.hanSansNeo(12,.regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#EBEBEB"))
        }
        .shadow(color: .gray.opacity(0.2), radius: 2)
    }
}

#Preview {
    BookMarkRow()
}
