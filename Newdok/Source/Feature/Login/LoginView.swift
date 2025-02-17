//
//  LoginView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI

struct LoginView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            HStack() {
                Image("logo")
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 0))
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("아이디")
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                TextField("아이디를 입력하세요", text: $viewModel.userId)
                
                Text("비밀번호")
                TextField("비밀번호를 입력해주세요", text: $viewModel.userPwd)
            }
            .padding(.leading, 28)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Color.clear.frame(height: 20) 
        }
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LoginView()
}
