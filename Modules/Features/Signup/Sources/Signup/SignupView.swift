//
//  SignupView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import DesignSystem

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
        case .enterProfile: return 0.7
        case .agreeTerms: return 0.9
        }
    }
}

public struct SignupView: View {
    @State private var currentStep: SignupStep = .phoneVerification
    @StateObject public var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack {
            ProgressView(value: currentStep.progressValue, total: 1.0)
                .progressViewStyle(.linear)
            
            TabView(selection: $currentStep) {
                PhoneVerificationView(viewModel: viewModel, nextStep: nextStep)
                    .tag(SignupStep.phoneVerification)
                
                
                IDInputView(viewModel: viewModel,nextStep: nextStep)
                    .tag(SignupStep.idInput)
                
                PwInputView(viewModel: viewModel, nextStep: nextStep)
                    .tag(SignupStep.pwInput)
                
                ProfileInputView(viewModel: viewModel, nextStep: nextStep)
                    .tag(SignupStep.enterProfile)
                
                AgreeView(viewModel: viewModel)
                    .tag(SignupStep.agreeTerms)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(DragGesture().onChanged { _ in })
        }
        .padding(.top, 20)
        
    }
    
    
    private func nextStep() {
        if let nextStep = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
}

//#Preview {
//    SignupView()
//}
