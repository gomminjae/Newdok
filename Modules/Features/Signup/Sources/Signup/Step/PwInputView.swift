//
//  PwInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem

public struct PwInputView: View {
    
    @State var pwdString: String = ""
    @State var pwdCheckString: String = ""
    
    @State var isSecure: Bool = true
    
    var nextStep: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("비밀번호를\n입력해주세요.")
                .font(.system(size: 18, weight: .bold))
            
            Text("비밀번호")
                .font(.headline)

            TextField("8자 이상, 영문/숫자 조합", text: $pwdString)
                .modifier(PasswordFieldModifier(isSecure: $isSecure))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("비밀번호 확인")
                .font(.headline)

            TextField("8자 이상, 영문/숫자 조합", text: $pwdCheckString)
                .modifier(PasswordFieldModifier(isSecure: $isSecure))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    PwInputView(nextStep: {})
}
