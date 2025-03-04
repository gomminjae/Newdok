//
//  IDInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct IDInputView: View {
    
    @State private var id: String = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("아이디를\n입력해주세요.")
                .font(.hanSansNeo(18, .bold))
            Text("아이디")
                .font(.hanSansNeo(14, .medium))
                .padding(.top, 32)
            HStack {
                TextField("6~12자,영문/숫자 조합", text: $id)
                    .font(.hanSansNeo(14, .medium))
                    .modifier(CustomTextFieldModifier(icon: "person"))
                    .frame(height: 56)
                Button("중복확인") {
                    print("text")
                }
                .frame(width: 96, height: 56)
                .foregroundStyle(Color(hex: "C0C0C0"))
                .background(Color(hex: "EBEBEB"))
                .cornerRadius(12)
            }
                
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
}

#Preview {
    IDInputView()
}
