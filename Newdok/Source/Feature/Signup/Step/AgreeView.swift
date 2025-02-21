//
//  AgreeView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct AgreeView: View {
    
    @State private var isOver14 = false
    @State private var serviceAgreement = false
    @State private var personalInfoAgreement = false
    @State private var marketingAgreement = false
    @State private var allAgreements = false
    
    var isSignUpEnabled: Bool {
        return isOver14 && serviceAgreement && personalInfoAgreement
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header Text
            Text("마지막으로\n이용 약관에 동의해주세요.")
                .font(.hanSansNeo(12,.bold))
                .bold()
                .padding(.top,32)
            
            // Agreement List
            VStack {
                AgreementRow(title: "만 14세 이상 확인 (필수)", isChecked: $isOver14)
                AgreementRow(title: "서비스 이용 동의 (필수)", isChecked: $serviceAgreement)
                AgreementRow(title: "개인정보 수집 및 이용 동의 (필수)", isChecked: $personalInfoAgreement)
                AgreementRow(title: "마케팅 활용/광고성 정보 수신 동의 (선택)", isChecked: $marketingAgreement)
                
                Divider()
                
             
                HStack {
                    Text("전체 약관 동의")
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        allAgreements.toggle()
                        isOver14 = allAgreements
                        serviceAgreement = allAgreements
                        personalInfoAgreement = allAgreements
                        marketingAgreement = allAgreements
                    }) {
                        Image(allAgreements ? "check" : "uncheck")
                    }
                }
            }
            
            Spacer()
            
            
            // Sign-up Button
            Button(action: {
                // Sign-up action here
            }) {
                Text("가입완료")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isSignUpEnabled ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 16)
            .disabled(!isSignUpEnabled)
            
            
        }
        .padding(.horizontal,24)
    }
}

struct AgreementRow: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(isChecked ? "check" : "uncheck")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(isChecked ? .blue : .gray)
                .onTapGesture {
                    isChecked.toggle()
                }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AgreeView()
}
