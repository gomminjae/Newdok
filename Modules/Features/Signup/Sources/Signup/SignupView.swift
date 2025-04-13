//
//  SignupView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//
import SwiftUI
import DesignSystem
import Shared

public enum SignupStep: Int, CaseIterable {
    case phoneVerification = 0
    case idInput = 1
    case pwInput = 2
    case enterProfile = 3
    case agreeTerms = 4
    case complete = 5

    
    var progressValue: Double {
        switch self {
        case .phoneVerification: return 0.2
        case .idInput: return 0.4
        case .pwInput: return 0.6
        case .enterProfile: return 0.7
        case .agreeTerms: return 0.9
        default: return 1.0
        }
    }
    
    var title: String {
        switch self {
        case .phoneVerification:
            return "회원가입"
        case .idInput:
            return "회원가입"
        case .pwInput:
            return "회원가입"
        case .enterProfile:
            return "회원가입"
        case .agreeTerms:
            return "회원가입"
        case .complete:
            return "회원가입 완료"
        }
    }
}

public struct SignupView: View {
    @State private var currentStep: SignupStep = .idInput
    @StateObject public var viewModel: SignupViewModel
    
    @EnvironmentObject private var router: AppRouter


    public init(viewModel: SignupViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }

    public var body: some View {
        VStack(spacing: 0) {
            signupHeaderView

            Group {
                switch currentStep {
                case .phoneVerification:
                    PhoneVerificationView(viewModel: viewModel, nextStep: nextStep)
                        .environmentObject(router)


                case .idInput:
                    IDInputView(viewModel: viewModel, nextStep: nextStep)
                     

                case .pwInput:
                    PwInputView(viewModel: viewModel, nextStep: nextStep)
                     

                case .enterProfile:
                    ProfileInputView(viewModel: viewModel, nextStep: nextStep)
                       

                case .agreeTerms:
                    AgreeView(viewModel: viewModel, nextStep: nextStep)
                       
                case .complete:
                    CompleteView()
                       
                }
            }
            .animation(.easeInOut, value: currentStep)
            .interactiveDismissDisabled()
        }
        .ignoresSafeArea(.keyboard)
    }

    private func nextStep() {
        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }

    private func previousStepOrExit() {
        if currentStep == .phoneVerification {
            router.pop()
        } else if let prev = SignupStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }

    private var signupHeaderView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    previousStepOrExit()
                }) {
                    Image(asset: DesignSystemAsset.back)
                        .padding(.leading, 20)
                }

                Spacer()

                Text(currentStep.title)
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
                    .frame(height: 44)
                    .background(Color.white)

                Spacer()

                Spacer().frame(width: 40)
            }
            
            .contentShape(Rectangle())

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(hex: "#ECF3FF"))
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.primaryNormal)
                        .frame(width: geometry.size.width * currentStep.progressValue, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: currentStep)
                }
            }
            .frame(height: 4)
        }
        .navigationBarHidden(true)
    }
    
}
