//
//  AgreeView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem

public struct AgreeView: View {
    @State private var isOver14 = false
    @State private var serviceAgreement = false
    @State private var personalInfoAgreement = false
    @State private var marketingAgreement = false
    
    
    var nextStep: () -> Void
    
    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel, nextStep: @escaping () -> Void) {
            self.viewModel = viewModel
            self.nextStep = nextStep
        }

    var isSignUpEnabled: Bool {
        return isOver14 && serviceAgreement && personalInfoAgreement
    }

    var isAllAgreed: Bool {
        return isOver14 && serviceAgreement && personalInfoAgreement && marketingAgreement
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("마지막으로\n이용 약관에 동의해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                AgreementRow(title: "만 14세 이상 확인 (필수)", isChecked: $isOver14)
                AgreementRow(title: "서비스 이용 동의 (필수)", isChecked: $serviceAgreement)
                AgreementRow(title: "개인정보 수집 및 이용 동의 (필수)", isChecked: $personalInfoAgreement)
                AgreementRow(title: "마케팅 활용 동의 (선택)", isChecked: $marketingAgreement)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            Divider()
                .padding(.horizontal, 24)

            
            HStack {
                Text("전체 약관 동의")
                    .font(.hanSansNeo(16, .medium))

                Spacer()

                Button(action: {
                    let toggleValue = !isAllAgreed
                    isOver14 = toggleValue
                    serviceAgreement = toggleValue
                    personalInfoAgreement = toggleValue
                    marketingAgreement = toggleValue
                }) {
                    Image(asset: isAllAgreed ? DesignSystemAsset.allcheck : DesignSystemAsset.uncheck)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button("가입완료") {
                print("회원가입 완료!")
                nextStep()
            }
            .font(.hanSansNeo(14,.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isSignUpEnabled ? Color.primaryNormal : Color.lineNeutral)
            .foregroundColor(.white)
            .cornerRadius(4)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
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
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                isChecked.toggle()
            }) {
                Image(asset: isChecked ? DesignSystemAsset.check : DesignSystemAsset.uncheck)
            }
        }
    }
}
