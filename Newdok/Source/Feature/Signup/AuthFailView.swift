//
//  AuthFailView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct AuthFailView: View {
    var body: some View {
        VStack {
            Image("warning")
            Text("인증에 실패하였습니다.")
            Text("인증 횟수를 초과했습니다.\n처음부터 다시 진행해주세요.")
            Button("처음으로") {
                print("Hello")
            }
            .foregroundStyle(Color.white)
            .background(Color(hex: "2866D3"))
        }
        .background(.white)
    }
        
}

#Preview {
    AuthFailView()
}
