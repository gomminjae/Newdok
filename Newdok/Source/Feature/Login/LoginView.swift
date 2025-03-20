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
    @State private var showHomeView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image("logo")
                        .frame(alignment: .leading)
                        .padding(.leading, 28)
                    Spacer()
                }
                .padding(.bottom, 24)
                
                VStack(alignment: .leading) {
                    Text("아이디")
                        .font(.hanSansNeo(14, .medium))
                    TextField("아이디를 입력하세요", text: $viewModel.userId)
                        .font(.hanSansNeo(14, .medium))
                        .frame(height: 56)
                        .customTextFieldStyle(icon: "person")
                    
                    Text("비밀번호")
                        .font(.hanSansNeo(14, .medium))
                        .padding(.top, 28)
                 
                    TextField("비밀번호를 입력해주세요", text: $viewModel.userPwd)
                        .font(.hanSansNeo(14, .medium))
                        .frame(height: 56)
                        .modifier(PasswordFieldModifier(isSecure: $viewModel.isUserPwdValid))
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            print("로그인 비밀번호 찾기")
                        }) {
                            Text("아이디/비밀번호 찾기")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color(hex: "565656"))
                        }
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Button(action: {
                        print("버튼 클릭됨")
                    }) {
                        Text("로그인")
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(hex: "#EBEBEB"))
                            .foregroundColor(Color(hex: "#C0C0C0"))
                            .cornerRadius(4)
                    }
                    
                    HStack {
                        Button(action: {
                            showHomeView = true
                        }) {
                            Text("비회원으로 이용하기")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color(hex: "565656"))
                        }
                        .padding(.leading, 97)

                        Text("|")
                            .foregroundStyle(Color(hex: "#DADADA"))
                        
                        Button(action: {
                            print("회원가입")
                        }) {
                            Text("회원가입")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color(hex: "#2866D3"))
                        }
                    }
                    .padding(.bottom, 56)
                    
                }
                .padding(.horizontal, 24)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 20)
            }
            .fullScreenCover(isPresented: $showHomeView) {
                NewDokTabView()
            }
        }
        .navigationBarHidden(true)
    }
}



#Preview {
    LoginView()
}
