//
//  IDInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import Combine

public struct IDInputView: View {
    
    @ObservedObject private var viewModel: SignupViewModel
    
    
    var nextStep: () -> Void
    
    public init(viewModel: SignupViewModel, nextStep: @escaping () -> Void) {
        self.viewModel = viewModel
        self.nextStep = nextStep
    }
    
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("아이디를\n입력해주세요.")
                .font(.hanSansNeo(18, .bold))
                .padding(.top,24)
            Text("아이디")
                .font(.hanSansNeo(14, .medium))
                .padding(.top, 32)
            HStack {
                TextField("6~12자,영문/숫자 조합", text: $viewModel.loginID)
                    .font(.hanSansNeo(14, .medium))
                    .modifier(CustomTextFieldModifier())
                    .frame(height: 56)
                Button("중복확인") {
                    viewModel.checkIDDup()
                }
                .frame(width: 94, height: 48)
                .foregroundStyle(viewModel.isIDAvailable ?? false ? Color.primaryNormal : Color(hex: "C0C0C0"))
                .overlay {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(viewModel.isIDAvailable ?? false ? Color.primaryNormal : Color(hex: "C0C0C0"))
                }
            }
            Spacer()
                
        }
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .hideKeyboardOnTap()
        
    }
    
}
//
//#Preview {
//    IDInputView(nextStep: {})
//}
