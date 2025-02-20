//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

struct CurationRow: View {
    var body: some View {
        VStack {
            HStack {
                Image("signup")
                    .resizable()
                    .background(Color.orange)
                    .frame(width: 45, height: 45)
                    .cornerRadius(12)
                VStack {
                    Text("Gello")
                    HStack {
                        Text("123")
                            
                    }
                }
                Spacer()
                Button(action: {}) {
                    Text("구독하기")
                        .foregroundStyle(.white)
                }
                .padding(.vertical,22)
                .background(Color.blue)
            }
            Text("뉴스레터 간단 소개글은 최대 25자까지 입니다.")
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    CurationRow()
}
