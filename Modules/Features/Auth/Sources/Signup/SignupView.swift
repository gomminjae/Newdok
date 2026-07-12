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
    case enterProfile = 0
    case agreeTerms = 1
    case complete = 2
    case recommend = 3
    case myIndustry = 4
    case indutryList = 5
    case curation = 6

    var progressValue: Double {
        switch self {
        case .enterProfile: return 0.5
        case .agreeTerms: return 0.9
        case .myIndustry: return 0.3
        case .indutryList: return 0.7
        case .curation: return 1.0

        default: return 1.0
        }
    }

    var title: String {
        switch self {
        case .enterProfile:
            return "회원가입"
        case .agreeTerms:
            return "회원가입"
        case .complete:
            return "회원가입 완료"
        case .recommend:
            return "회원가입 완료"
        case .myIndustry:
            return "프로필 설정"
        case .indutryList:
            return "프로필 설정"
        case .curation:
            return "추천 뉴스레터"
        }
    }
}

public struct SignupView: View {
    @State public var viewModel: SignupViewModel

    private let onBack: () -> Void
    private let onLogin: () -> Void
    private let onRecovery: () -> Void
    private let onAuthenticated: () -> Void

    public init(
        viewModel: SignupViewModel,
        onBack: @escaping () -> Void,
        onLogin: @escaping () -> Void,
        onRecovery: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onLogin = onLogin
        self.onRecovery = onRecovery
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        VStack(spacing: 0) {
            signupHeaderView

            Group {
                switch viewModel.currentStep {
                case .enterProfile:
                    ProfileInputView(viewModel: viewModel)
                case .agreeTerms:
                    AgreeView(viewModel: viewModel)
                case .complete:
                    CompleteView(viewModel: viewModel)
                case .recommend:
                    RecommendView(viewModel: viewModel)
                case .myIndustry:
                    MyIndustryView(viewModel: viewModel)
                case .indutryList:
                    InterestSelectionView(viewModel: viewModel)
                case .curation:
                    CurationView(viewModel: viewModel, onAuthenticated: onAuthenticated)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        }
        .ignoresSafeArea(.keyboard)
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { onBack() },
            onRetry: {}
        )
    }

    private func nextStep() {
        viewModel.goToNextStep()
    }

    private func previousStepOrExit() {
        if viewModel.currentStep == .enterProfile {
            onBack()
        } else {
            viewModel.goToPreviousStep()
        }
    }

    private var signupHeaderView: some View {
        VStack(spacing: 0) {
            HStack {
                if viewModel.currentStep.rawValue < SignupStep.complete.rawValue {
                    Button(action: {
                        previousStepOrExit()
                    }) {
                        Image(asset: DesignSystemAsset.back)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.leading, 8)
                } else {
                    Spacer().frame(width: 44)
                }

                Spacer()

                Text(viewModel.currentStep.title)
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
                    .frame(height: 44)
                    .background(Color.white)

                Spacer()

                if viewModel.currentStep == .recommend {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            onAuthenticated()
                        }
                    }) {
                        Text("건너뛰기")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.primaryNormal)
                            .underline()
                            .frame(width: 60, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 8)
                    .transition(.opacity)
                } else {
                    Spacer().frame(width: 44)
                }
            }
            
            .contentShape(Rectangle())

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.primaryBg)
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
        }
        .navigationBarHidden(true)
    }
}
