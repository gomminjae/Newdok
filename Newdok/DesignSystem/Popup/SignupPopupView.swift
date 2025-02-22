//
//  SignupPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/22/25.
//

import SwiftUI

struct SignupPopupView: View {
    var emails: [String]
    var onClose: () -> Void
    var onLogin: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }

            VStack {
                Image("warning")
                    .resizable()
                    .frame(width: 80,height: 80)
                    .padding(.top, 20)
                    .padding(.bottom,6)
                    
                Text("이미 가입된 정보입니다.")
                    .font(.hanSansNeo(18,.bold))
                    

                Text("한 번호로 최대 3개의\n계정을 만들 수 있어요.")
                    .font(.hanSansNeo(14,.regular))
                    .foregroundStyle(Color(hex: "555555"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    

               
                VStack(alignment: .leading) {
                    ForEach(emails, id: \.self) { email in
                        VStack(alignment: .leading) {
                            Text(email)
                                .font(.hanSansNeo(14, .regular))
                                .foregroundColor(Color.primaryNormal)

                            Text("\(generateRandomDate())")
                                .font(.hanSansNeo(12, .regular))
                                .foregroundColor(Color(hex: "333333"))
                            
                        }
                        .frame(alignment: .leading)
                        
                        .padding(.horizontal, 16)
                        .padding(.bottom, email == emails.last ? 16 : 10)
                        .padding(.top, email == emails.first ? 16 : 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(4)
                .padding(.top,24)
                .padding(.horizontal, 20)
                
                
                HStack(spacing: 12) {
                    
                    Button(emails.count < 3 ? "계속 진행하기":"ID/FW 찾기") {
                        print("ID/FW 찾기 클릭")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.primaryNormal, lineWidth: 1)
                    )
                    .font(.hanSansNeo(14,.bold))
                    .foregroundColor(Color.primaryNormal)

                    Button("로그인") {
                        onLogin()
                    }
                    .font(.hanSansNeo(14,.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.primaryNormal)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 28)
          
            
        }
        
    }


    private func generateRandomDate() -> String {
        let dates = ["2023.05.12 가입", "2023.06.12 가입", "2023.07.12 가입"]
        return dates.randomElement() ?? "2023.01.01 가입"
    }
}


#Preview("1개 이메일") {
    SignupPopupView(
        emails: ["aaa6***"],
        onClose: {},
        onLogin: {}
    )
}

#Preview("2개 이메일") {
    SignupPopupView(
        emails: ["aaa6***", "aaa5***"],
        onClose: {},
        onLogin: {}
    )
}

#Preview("3개 이메일") {
    SignupPopupView(
        emails: ["aaa6***", "aaa5***", "aaa4***"],
        onClose: {},
        onLogin: {}
    )
}
