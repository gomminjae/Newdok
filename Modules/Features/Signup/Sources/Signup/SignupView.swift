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
    @StateObject public var viewModel: SignupViewModel
    
    @EnvironmentObject private var router: AppRouter


    public init(viewModel: SignupViewModel) {
            _viewModel = StateObject(wrappedValue: viewModel)
        }

    public var body: some View {
        VStack(spacing: 0) {
            signupHeaderView

            Group {
                switch viewModel.currentStep {
                case .phoneVerification:
                    PhoneVerificationView(viewModel: viewModel)
                        .environmentObject(router)


                case .idInput:
                    IDInputView(viewModel: viewModel)
                     

                case .pwInput:
                    PwInputView(viewModel: viewModel)
                     

                case .enterProfile:
                    ProfileInputView(viewModel: viewModel)
                       

                case .agreeTerms:
                    AgreeView(viewModel: viewModel, nextStep: nextStep)
                       
                case .complete:
                    CompleteView()
                       
                }
            }
            .animation(.easeInOut, value: viewModel.currentStep)
            .interactiveDismissDisabled()
        }
        .ignoresSafeArea(.keyboard)
    }

    private func nextStep() {
        viewModel.goToNextStep()
    }

    private func previousStepOrExit() {
        if viewModel.currentStep == .phoneVerification {
            router.pop()
        } else {
            viewModel.goToPreviousStep()
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

                Text(viewModel.currentStep.title)
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
                        .frame(width: geometry.size.width * viewModel.currentStep.progressValue, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
                }
            }
            .frame(height: 4)
        }
        .onAppear {
            print("🧩 SignupViewModel address: \(Unmanaged.passUnretained(viewModel).toOpaque())")
        }
        .navigationBarHidden(true)
    }
    
}
