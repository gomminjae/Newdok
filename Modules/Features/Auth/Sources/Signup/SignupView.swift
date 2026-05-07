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
    case recommend = 6
    case myIndustry = 7
    case indutryList = 8
    case curation = 9

    var progressValue: Double {
        switch self {
        case .phoneVerification: return 0.1
        case .idInput: return 0.3
        case .pwInput: return 0.5
        case .enterProfile: return 0.7
        case .agreeTerms: return 0.9
        case .myIndustry: return 0.3
        case .indutryList: return 0.7
        case .curation: return 1.0
        
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

    @Environment(AppRouter.self) private var router

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            signupHeaderView

            Group {
                switch viewModel.currentStep {
                case .phoneVerification:
                    PhoneVerificationView(viewModel: viewModel)
                        .environment(router)
                case .idInput:
                    IDInputView(viewModel: viewModel)
                case .pwInput:
                    PwInputView(viewModel: viewModel)
                case .enterProfile:
                    ProfileInputView(viewModel: viewModel)
                case .agreeTerms:
                    AgreeView(viewModel: viewModel)
                case .complete:
                    CompleteView(viewModel: viewModel)
                        .environment(router)
                case .recommend:
                    RecommendView(viewModel: viewModel)
                case .myIndustry:
                    MyIndustryView(viewModel: viewModel)
                case .indutryList:
                    InterestSelectionView(viewModel: viewModel)
                case .curation:
                    CurationView(viewModel: viewModel)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        }
        .ignoresSafeArea(.keyboard)
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: {}
        )
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
                if viewModel.currentStep.rawValue < SignupStep.complete.rawValue {
                    Button(action: {
                        previousStepOrExit()
                    }) {
                        Image(asset: DesignSystemAsset.back)
                            .padding(.leading, 20)
                    }
                } else {
                    Spacer().frame(width: 40)
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
                            router.resetTo(.tabbar(selectedTab: .home))
                        }
                    }) {
                        Text("건너뛰기")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(.primaryNormal)
                            .padding(.trailing, 20)
                            .underline()
                    }
                    .transition(.opacity)
                } else {
                    // 위치 유지를 위한 빈 공간
                    Spacer().frame(width: 40)
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
