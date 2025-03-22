//
//  SignupView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI

public enum SignupStep: Int, CaseIterable {
    case phoneVerification = 0
    case idInput
    case pwInput
    case enterProfile
    case agreeTerms

    
    var progressValue: Double {
        switch self {
        case .phoneVerification: return 0.2
        case .idInput: return 0.4
        case .pwInput: return 0.6
        case .enterProfile: return 0.8
        case .agreeTerms: return 1.0
        }
    }
}

public struct SignupView: View {
    @State private var currentStep: SignupStep = .phoneVerification

    var body: some View {
        VStack {
            ProgressView(value: currentStep.progressValue, total: 1.0)
                .progressViewStyle(.linear)

            TabView(selection: $currentStep) {
                PhoneVerificationView(nextStep: nextStep)
                    .tag(SignupStep.phoneVerification)
                
                IDInputView(nextStep: nextStep)
                    .tag(SignupStep.idInput)
                
                PwInputView(nextStep: nextStep)
                    .tag(SignupStep.pwInput)
                
                ProfileInputView(nextStep: nextStep)
                    .tag(SignupStep.enterProfile)

                AgreeView()
                    .tag(SignupStep.agreeTerms)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(DragGesture().onChanged { _ in })
        }
        .padding(.top, 20)
        .navigationTitle("회원가입")
    }

    // ✅ 다음 단계로 이동하는 함수
    private func nextStep() {
        if let nextStep = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
}

#Preview {
    SignupView()
}
