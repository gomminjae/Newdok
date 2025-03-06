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

    var isSignUpEnabled: Bool {
        return isOver14 && serviceAgreement && personalInfoAgreement
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("마지막으로\n이용 약관에 동의해주세요.")
                .font(.title2)
                .bold()
                .padding(.top, 32)

            VStack {
                AgreementRow(title: "만 14세 이상 확인 (필수)", isChecked: $isOver14)
                AgreementRow(title: "서비스 이용 동의 (필수)", isChecked: $serviceAgreement)
                AgreementRow(title: "개인정보 수집 및 이용 동의 (필수)", isChecked: $personalInfoAgreement)
                AgreementRow(title: "마케팅 활용 동의 (선택)", isChecked: $marketingAgreement)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button("가입완료") {
                print("회원가입 완료!")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSignUpEnabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 16)
            .disabled(!isSignUpEnabled)
        }
    }
}

struct AgreementRow: View {
    let title: String
    @Binding var isChecked: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: $isChecked)
                .labelsHidden()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    AgreeView()
}
