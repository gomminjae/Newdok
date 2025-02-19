//
//  PhoneVerificationView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
import SwiftUI
import Combine

struct PhoneVerificationView: View {
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var isRequestSent: Bool = false
    @State private var isCodeValid: Bool = true
    @State private var timerRemaining: Int = 180
    @State private var isTimerActive: Bool = false
    @State private var showError: Bool = false
    @State private var showAlreadyRegisteredAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("본인 확인을 위해\n휴대폰 번호를 입력해주세요.")
                .font(.title2)
                .bold()
            Text("휴대폰 번호")
                .font(Font.system(size: 14))
                .padding(.top, 48)
            HStack {
                HStack {
                    Image(systemName: "phone.fill") // 📌 아이콘 추가
                        .foregroundColor(.gray)
                    // 🔹 휴대폰 번호 입력 필드
                    TextField("-구분 없이 입력", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding()
                        .frame(height: 36)
                        .onReceive(Just(phoneNumber)) { new in
                            let formatted = formatPhoneNumber(new)
                            if formatted != self.phoneNumber {
                                self.phoneNumber = formatted
                            }
                        }
                        .font(Font.system(size: 14))
                        .disabled(isRequestSent)
                }
                .padding(.bottom, 5)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "#EBEBEB")), alignment: .bottom)
                
                // 🔹 인증 요청 버튼
                Button(isRequestSent ? "재전송" : "인증 요청") {
                    sendVerificationCode()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(phoneNumber.isEmpty || isRequestSent)
                .frame(width: 84, height: 36)
                .cornerRadius(8)
            }

            if isRequestSent {
                // 🔹 인증번호 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    Text("인증번호")
                        .font(Font.system(size: 16))
                    HStack {
                        TextField("인증번호 입력", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(height: 50)
                        Text("\(formatTime(timerRemaining))")
                            .foregroundStyle(showError ? Color.red : Color(hex: "#2866D3"))
                            .font(Font.system(size: 12))
                            .padding(.trailing, 10)
                        
                    }
                    .border(Color(hex: "#EBEBEB"), width: 0.5)
                    .background(showError ? Color.red.opacity(0.1) : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(showError ? Color.red : Color(hex: "#EBEBEB"), lineWidth: 1)
                    )
                    
                    if showError {
                        Text("인증번호를 다시 확인해주세요.")
                            .foregroundStyle(.red)
                            .font(Font.system(size: 12))
                    }
                    
                }
                
                
                Spacer()
                // 🔹 "다음" 버튼
                Button("다음") {
                    verifyCode()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(verificationCode.count < 6)
            }
        }
        .padding(.leading, 24)
        .alert(isPresented: $showAlreadyRegisteredAlert) {
            Alert(title: Text("이미 가입된 계정입니다."),
                  message: Text("이메일을 확인해주세요."),
                  dismissButton: .default(Text("계속")))
        }
        .onAppear {
            if isTimerActive {
                startTimer()
            }
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        let maxLength = 11
        
        var formattedNumber = ""
        
        for (index,ch) in digits.prefix(maxLength).enumerated() {
            if index == 3 || index == 7 {
                formattedNumber.append("-")
            }
            formattedNumber.append(String(ch))
        }
        return formattedNumber
    }
    
  
    private func sendVerificationCode() {
        isRequestSent = true
        isTimerActive = true
        startTimer()
        
    }
    
    // 🔹 인증번호 검증
    private func verifyCode() {
        if verificationCode == "123456" {
            print("인증 성공!")
        } else {
            isCodeValid = false
            showError = true
        }
    }
    

    private func resendCode() {
        timerRemaining = 180
        startTimer()
    }
    
  
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerRemaining > 0 {
                timerRemaining -= 1
            } else {
                timer.invalidate()
                isTimerActive = false
            }
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(configuration.isPressed ? .gray : Color(hex: "#2866D3"))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.vertical, 5)
    }
}

#Preview {
    PhoneVerificationView()
}
