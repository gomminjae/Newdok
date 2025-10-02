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

    @ObservedObject private var viewModel: SignupViewModel

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
                AgreementRow(title: "만 14세 이상 확인 (필수)", isChecked: $isOver14)

                AgreementRow(title: "서비스 이용 동의 (필수)", isChecked: $serviceAgreement) {
                    sheetType = .terms
                    showSheet = true
                }

                AgreementRow(title: "개인정보 수집 및 이용 동의 (필수)", isChecked: $personalInfoAgreement) {
                    sheetType = .privacy
                    showSheet = true
                }

                

                AgreementRow(title: "마케팅 활용/광고성 정보 수신 동의 (선택)", isChecked: $marketingAgreement)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            Divider().padding(.horizontal, 24)

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

            Button("가입완료") {
                viewModel.signup()
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
                // 시트가 닫힐 때 해당 약관 체크
                if let type = sheetType {
                    switch type {
                    case .terms:
                        serviceAgreement = true
                    case .privacy:
                        personalInfoAgreement = true
                    }
                }
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


struct AgreementRow: View {
    let title: String
    @Binding var isChecked: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(.black)

            Spacer()

            Button(action: {
                onTap?() ?? isChecked.toggle()
            }) {
                Image(asset: isChecked ? DesignSystemAsset.check : DesignSystemAsset.uncheck)
            }
        }
    }
}
