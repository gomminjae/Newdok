//
//  IDInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem

struct IDInputView: View {
    
    @State private var id: String = ""
    @State private var isDuplicated: Bool = false
    @State private var isCompleted: Bool = false
    
    var nextStep: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("아이디를\n입력해주세요.")
                .font(.hanSansNeo(18, .bold))
                .padding(.top,24)
            Text("아이디")
                .font(.hanSansNeo(14, .medium))
                .padding(.top, 32)
            HStack {
                TextField("6~12자,영문/숫자 조합", text: $id)
                    .font(.hanSansNeo(14, .medium))
                    .modifier(CustomTextFieldModifier())
                    .frame(height: 56)
                Button("중복확인") {
                    print("text")
                }
                .frame(width: 94, height: 48)
                .foregroundStyle(validate(id) ? Color.primaryNormal : Color(hex: "C0C0C0"))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(validate(id) ? Color.primaryNormal : Color(hex: "C0C0C0"))
                }
            }
            Spacer()
                
        }
        .padding(.leading, 24)
        .padding(.trailing, 24)
    }
    
    func validate(_ id: String) -> Bool {
        let regex = "^[a-z0-9]{6,12}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: id)
    }
}

#Preview {
    IDInputView(nextStep: {})
}
