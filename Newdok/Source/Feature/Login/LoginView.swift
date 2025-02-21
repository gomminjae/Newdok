//
//  LoginView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    var icon: String
    
    func body(content: Content) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)

            content
                .foregroundColor(.primary) 
                .padding(.vertical, 12)
            
        }
        .padding(.horizontal)
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
extension View {
    func customTextFieldStyle(icon: String) -> some View {
        self.modifier(CustomTextFieldModifier(icon: icon))
    }
}

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
                    .font(.hanSansNeo(14,.medium))
                    .frame(alignment: .leading)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                TextField("아이디를 입력하세요", text: $viewModel.userId)
                    .font(.hanSansNeo(14,.medium))
                    .frame(height: 56)
//                    .border(Color(hex: "#E5E5E5"), width: 1)
                    .customTextFieldStyle(icon: "person")
                    
                    
                
                Text("비밀번호")
                    .font(.hanSansNeo(14,.medium))
                    .padding(.top,28)
                TextField("비밀번호를 입력해주세요", text: $viewModel.userPwd)
                    .font(.hanSansNeo(14,.medium))
                    .frame(height: 56)
                    .customTextFieldStyle(icon: "lock")
                HStack {
                    Spacer()
                    Button(action: {
                        print("로그인 비밀번호 찾기")
                    }) {
                        Text("아이디/비밀번호 찾기")
                            .font(.hanSansNeo(14,.medium))
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
              
                
                HStack {
                    Button(action: {
                        print("회원가입")
                    }) {
                        Text("비회원으로 이용하기")
                            .font(.hanSansNeo(14,.medium))
                            .foregroundStyle(Color(hex: "555555"))
                    }
                    .padding(.leading,97)
                    Text("|")
                        .foregroundStyle(Color(hex: "#DADADA"))
                    Button(action: {
                        print("회원가입")
                    }) {
                        Text("회원가입")
                            .font(.hanSansNeo(14,.medium))
                            .foregroundStyle(Color(hex: "#2866D3"))
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
