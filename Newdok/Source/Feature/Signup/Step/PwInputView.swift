//
//  PwInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct PwInputView: View {
    
    @Binding var pwdString: String
    @Binding var pwdCheckString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("비밀번호를\n입력해주세요.")
                .font(.system(size: 18, weight: .bold))
            
            Text("비밀번호")
                .font(.headline)

            TextField("8자 이상, 영문/숫자 조합", text: $pwdString)
                .modifier(CustomTextFieldModifier(icon: "lock"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("비밀번호 확인")
                .font(.headline)

            TextField("8자 이상, 영문/숫자 조합", text: $pwdCheckString)
                .modifier(CustomTextFieldModifier(icon: "lock"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }
}

