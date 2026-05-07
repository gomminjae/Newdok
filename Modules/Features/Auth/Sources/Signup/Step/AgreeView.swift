//
//  AgreeView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import WebKit

public struct AgreeView: View {
    @State private var isOver14 = false
    @State private var serviceAgreement = false
    @State private var personalInfoAgreement = false
    @State private var marketingAgreement = false

    @State private var showSheet = false
    @State private var sheetType: SheetType?

    @Bindable private var viewModel: SignupViewModel

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("마지막으로\n이용 약관에 동의해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)
                .padding(.horizontal, 24)

            VStack(spacing: 16) {
                // 버튼 없는 행
                SimpleAgreementRow(title: "만 14세 이상 확인", required: true, isChecked: $isOver14)
                
                // 버튼 있는 행
                TappableAgreementRow(
                    mainText: "서비스 이용",
                    required: true,
                    isChecked: $serviceAgreement,
                    onTextTap: {
                        sheetType = .terms
                        showSheet = true
                    }
                )
                
                TappableAgreementRow(
                    mainText: "개인정보 수집 및 이용",
                    required: true,
                    isChecked: $personalInfoAgreement,
                    onTextTap: {
                        sheetType = .privacy
                        showSheet = true
                    }
                )
                
                // 버튼 없는 행
                SimpleAgreementRow(title: "마케팅 활용/광고성 정보 수신", required: false, isChecked: $marketingAgreement)
            }
            .padding(.top, 8)
            .padding(.horizontal, 24)

            Divider()
                .background(Color.captionDisabled)
                .padding(.horizontal, 24)

            HStack {
                Text("전체 약관 동의")
                    .font(.hanSansNeo(16, .medium))
                Spacer()
                Button {
                    let toggle = !(isOver14 && serviceAgreement && personalInfoAgreement && marketingAgreement)
                    isOver14 = toggle
                    serviceAgreement = toggle
                    personalInfoAgreement = toggle
                    marketingAgreement = toggle
                } label: {
                    Image(asset: isAllAgreed ? DesignSystemAsset.allcheck : DesignSystemAsset.uncheck)
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: {
                viewModel.signup()
            }) {
                Group {
                    if viewModel.isLoading {
                        LoadingDotsView()
                    } else {
                        Text("가입완료")
                            .font(.hanSansNeo(14, .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    viewModel.isLoading
                        ? Color.primaryBgSubtle
                        : (isSignUpEnabled ? Color.primaryNormal : Color.lineNeutral)
                )
                .foregroundColor(.white)
                .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(!isSignUpEnabled || viewModel.isLoading)
        }
        .sheet(isPresented: $showSheet) {
            if let type = sheetType {
                PolicyWebSheetView(type: type)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
                    .interactiveDismissDisabled(false)
            }
        }
        .onChange(of: showSheet) { _, isPresented in
            if !isPresented {
                sheetType = nil
            }
        }
    }

    private var isSignUpEnabled: Bool {
        isOver14 && serviceAgreement && personalInfoAgreement
    }

    private var isAllAgreed: Bool {
        isOver14 && serviceAgreement && personalInfoAgreement && marketingAgreement
    }

    enum SheetType {
        case terms
        case privacy

        var url: URL {
            switch self {
            case .terms:
                return URL(string: "https://newdok.notion.site/18aacf9713bc427a850ae8da92b69087?pvs=4")!
            case .privacy:
                return URL(string: "https://newdok.notion.site/82ef5aea46d84623b7b19bb951b6043c?pvs=4")!
            }
        }

        var title: String {
            switch self {
            case .terms: return "이용약관"
            case .privacy: return "개인정보처리방침"
            }
        }
    }
}

// 버튼 없는 단순 행 (만 14세, 마케팅)
struct SimpleAgreementRow: View {
    let title: String
    let required: Bool
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Text(title)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionStrong)
                
                Text(required ? " (필수)" : " (선택)")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionAssistive)
            }
            
            Spacer()
            
            Button(action: {
                isChecked.toggle()
            }) {
                Image(asset: isChecked ? DesignSystemAsset.check : DesignSystemAsset.uncheck)
            }
        }
    }
}

// 클릭 가능한 행 (서비스 이용, 개인정보)
struct TappableAgreementRow: View {
    let mainText: String
    let required: Bool
    @Binding var isChecked: Bool
    let onTextTap: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onTextTap) {
                HStack(spacing: 0) {
                    Text(mainText)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color.captionStrong)
                        .underline(true, color: Color.captionStrong)
                    
                    Text(" 동의")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color.captionStrong)
                    
                    Text(required ? " (필수)" : " (선택)")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color.captionAssistive)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action: {
                isChecked.toggle()
            }) {
                Image(asset: isChecked ? DesignSystemAsset.check : DesignSystemAsset.uncheck)
            }
        }
    }
}
