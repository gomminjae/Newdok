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

//public struct SignupView: View {
//    @State private var currentStep: SignupStep = .phoneVerification
//    @StateObject public var viewModel: SignupViewModel
//    
//    public init(viewModel: SignupViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//
//    public var body: some View {
//        VStack {
//            ProgressView(value: currentStep.progressValue, total: 1.0)
//                .progressViewStyle(.linear)
//                .tint(Color.primaryNormal)
//                .background(Color(hex: "#ECF3FF"))
//            
//            TabView(selection: $currentStep) {
//                PhoneVerificationView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.phoneVerification)
//                
//                
//                IDInputView(viewModel: viewModel,nextStep: nextStep)
//                    .tag(SignupStep.idInput)
//                
//                PwInputView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.pwInput)
//                
//                ProfileInputView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.enterProfile)
//                
//                AgreeView(viewModel: viewModel)
//                    .tag(SignupStep.agreeTerms)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            //.gesture(DragGesture().onChanged { _ in })
//        }
//        .padding(.top, 20)
//        
//    }
//    
//    
//    private func nextStep() {
//        if let nextStep = SignupStep(rawValue: currentStep.rawValue + 1) {
//            currentStep = nextStep
//        }
//    }
//}
//public struct SignupView: View {
//    @State private var currentStep: SignupStep = .phoneVerification
//    @StateObject public var viewModel: SignupViewModel
//
//    private let onBack: () -> Void
//
//    public init(viewModel: SignupViewModel, onBack: @escaping () -> Void) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//        self.onBack = onBack
//    }
//
//    public var body: some View {
//        VStack(spacing: 0) {
//            signupHeaderView
//
//            TabView(selection: $currentStep) {
//                PhoneVerificationView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.phoneVerification)
//
//                IDInputView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.idInput)
//
//                PwInputView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.pwInput)
//
//                ProfileInputView(viewModel: viewModel, nextStep: nextStep)
//                    .tag(SignupStep.enterProfile)
//
//                AgreeView(viewModel: viewModel)
//                    .tag(SignupStep.agreeTerms)
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            .animation(.easeInOut, value: currentStep)
//            .interactiveDismissDisabled()
//        }
//        .ignoresSafeArea(.keyboard)
//    }
//
//    private func nextStep() {
//        if let next = SignupStep(rawValue: currentStep.rawValue + 1) {
//            currentStep = next
//        }
//    }
//
//    private func previousStepOrExit() {
//        if currentStep == .phoneVerification {
//            onBack() // 첫 단계: 종료 또는 이전 화면 이동
//        } else if let prev = SignupStep(rawValue: currentStep.rawValue - 1) {
//            currentStep = prev
//        }
//    }
//
//    private var signupHeaderView: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Button(action: {
//                    previousStepOrExit()
//                }) {
//                    Image(asset: DesignSystemAsset.back)
//                        .padding(.leading, 20)
//                }
//
//                Spacer()
//
//                Text("회원가입")
//                    .font(.hanSansNeo(16, .bold))
//                    .foregroundColor(.black)
//
//                Spacer()
//
//                Spacer().frame(width: 40)
//            }
//            .frame(height: 44)
//            .background(Color.white)
//
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle()
//                        .fill(Color(hex: "#ECF3FF"))
//                        .frame(height: 4)
//
//                    Rectangle()
//                        .fill(Color.primaryNormal)
//                        .frame(width: geometry.size.width * currentStep.progressValue, height: 4)
//                        .animation(.easeInOut(duration: 0.2), value: currentStep)
//                }
//            }
//            .frame(height: 4)
//        }
//        .navigationBarHidden(true)
//    }
//}
public struct SignupView: View {
    @State private var currentStep: SignupStep = .phoneVerification
    @StateObject public var viewModel: SignupViewModel

    private let onBack: () -> Void

    public init(viewModel: SignupViewModel, onBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 0) {
            signupHeaderView

            ZStack {
                switch currentStep {
                case .phoneVerification:
                    PhoneVerificationView(viewModel: viewModel, nextStep: nextStep)

                case .idInput:
                    IDInputView(viewModel: viewModel, nextStep: nextStep)

                case .pwInput:
                    PwInputView(viewModel: viewModel, nextStep: nextStep)

                case .enterProfile:
                    ProfileInputView(viewModel: viewModel, nextStep: nextStep)

                case .agreeTerms:
                    AgreeView(viewModel: viewModel)
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
            onBack()
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

                Text("회원가입")
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

