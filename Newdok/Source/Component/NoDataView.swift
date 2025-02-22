//
//  NoDataView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//

import SwiftUI

struct NoDataView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Spacer()
                Button(action: {
                    print("refresh")
                }) {
                    Image("refresh")
                    Text("새로고침")
                        .font(.hanSansNeo(12,.regular))
                        .foregroundStyle(Color.primaryNormal)
                        .padding(.leading,4)
                        
                }
                .padding(.trailing, 28)
            }
            Image("nodata")
                .resizable()
                .frame(width: 240, height: 240)
            Text("오늘 도착한 아티클이 업어요.")
                .font(.hanSansNeo(16,.bold))
                .padding(.top, 24)
            Text("구독 신청 이후 수신된 아티클만 볼 수 있어요.")
                .font(.hanSansNeo(14,.regular))
                .padding(.top, 4)
            Button("수요일에 발행되는 뉴스레터 보기") {
                print("let's go")
            }
            .font(.hanSansNeo(16,.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primaryNormal)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
        }
    }
}

#Preview {
    NoDataView()
}
