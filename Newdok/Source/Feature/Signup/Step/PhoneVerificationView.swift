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
    
    var nextStep: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("본인 확인을 위해\n휴대폰 번호를 입력해주세요.")
                .font(.hanSansNeo(18, .bold))
                .padding(.leading, 24)
                .padding(.top,24)
            Text("휴대폰 번호")
                .font(.hanSansNeo(14,.medium))
                .padding(.top, 32)
                .padding(.leading,28)
            HStack {
                HStack {
                    Image("phone")
                        .foregroundColor(.gray)

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
                        .font(.hanSansNeo(14,.medium))
                        .disabled(isRequestSent)
                }
                .padding(.leading, 27)
                .padding(.bottom, 5)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color(hex: "#EBEBEB")), alignment: .bottom)
                
               
                Button(isRequestSent ? "재전송" : "인증 요청") {
                    sendVerificationCode()
                }
                .disabled(phoneNumber.isEmpty || isRequestSent)
                .buttonStyle(VerificationButtonStyle(
                    isRequestSent: isRequestSent,
                    isDisabled: phoneNumber.isEmpty || isRequestSent
                ))
                .padding(.horizontal, 24)

            }

            if isRequestSent {
                VStack(alignment: .leading, spacing: 8) {
                    Text("인증번호")
                        .font(Font.system(size: 16))
                        .padding(.leading, 24)
                        .padding(.top, 24)
                    HStack {
                        TextField("6자리 숫자 입력", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .frame(height: 50)
                            .padding(.leading, 16)
                            .font(.hanSansNeo(14, .medium))
                        Text("\(formatTime(timerRemaining))")
                            .foregroundStyle(showError ? Color.red : .primaryNormal)
                            .font(Font.system(size: 12))
                            .padding(.trailing, 10)
                        
                    }
                    .border(Color(hex: "#EBEBEB"), width: 0.5)
                    .background(showError ? Color.red.opacity(0.1) : .white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(showError ? Color.red : Color(hex: "EBEBEB"), lineWidth: 2)
                            .cornerRadius(12)
                    )
                    .padding(.horizontal,24)
                   
                    
                    Text(showError ? "인증번호를 다시 확인해주세요.":"문자가 오지 않는다면 '재전송'버튼을 눌러주세요.")
                        .font(.hanSansNeo(11, .regular))
                        .foregroundStyle(showError ? .red : Color(hex: "555555"))
                        .padding(.leading,24)
                        .padding(.top, 6)
                    
                    if showError {
                        Text("인증번호를 다시 확인해주세요.")
                            .foregroundStyle(.red)
                            .font(Font.system(size: 12))
                    }
                    
                }
                
                
                Spacer()
                
                Button("다음") {
                    verifyCode()
                }
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color.captionDisabled)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .disabled(verificationCode.count < 6)
                .background(verificationCode.count < 6 ? Color.lineNeutral : .primaryNormal)
                .cornerRadius(12)
                .padding(.horizontal,24)
                .padding(.bottom,16)
                
            } else {
                Spacer()
            }
        }
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
    
    private func verifyCode() {
        if verificationCode == "123456" {
            print("인증 성공!")
            nextStep()
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
            .background(configuration.isPressed ? .gray : .primaryNormal)
            .font(.hanSansNeo(14,.medium))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

#Preview {
    PhoneVerificationView(nextStep: {})
}
