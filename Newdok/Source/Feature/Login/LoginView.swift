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
            .padding(.bottom,24)
            VStack(alignment: .leading) {
                Text("아이디")
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                TextField("아이디를 입력하세요", text: $viewModel.userId)
                    .frame(height: 56)
                    .border(Color(hex: "#E5E5E5"), width: 1)
                    
                    
                
                Text("비밀번호")
                    .padding(.top,28)
                TextField("비밀번호를 입력해주세요", text: $viewModel.userPwd)
                    .frame(height: 56)
                    .border(Color(hex: "#E5E5E5"), width: 1)
                HStack {
                    Spacer()
                    Button(action: {
                        print("로그인 비밀번호 찾기")
                    }) {
                        Text("아이디/비밀번호 찾기")
                            .font(Font.system(size: 14))
                            .foregroundStyle(Color(hex: "#555555"))
                    }
                }
                .padding(.top,24)
                Spacer()
                Button(action: {
                    print("버튼 클릭됨")
                }) {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#EBEBEB"))
                        .foregroundColor(Color(hex: "#C0C0C0"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                HStack {
                    Button(action: {
                        print("회원가입")
                    }) {
                        Text("비회원으로 이용하기")
                            .font(Font.system(size: 14))
                    }
                    .padding(.leading,97)
                    Button(action: {
                        print("회원가입")
                    }) {
                        Text("회원가입")
                            .font(Font.system(size: 14))
                    }
                }
                .padding(.bottom, 56)
                
                
            }
            .padding(.leading, 24)
            .padding(.trailing, 24)
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
