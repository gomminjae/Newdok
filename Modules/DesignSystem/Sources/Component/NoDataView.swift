//
//  NoDataView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//

import SwiftUI

import SwiftUI

public enum NoDataType {
    case noArticles        // 도착한 아티클 없음
    case noSubscriptions   // 구독 중인 뉴스레터 없음
    case requireSignUp     // 회원가입 필요

    var imageName: DesignSystemImages {
        switch self {
        case .noArticles: return DesignSystemAsset.nodata
        case .noSubscriptions: return DesignSystemAsset.nosubscibe
        case .requireSignUp: return DesignSystemAsset.nologin
        }
    }

    var title: String {
        switch self {
        case .noArticles: return "오늘 도착한 아티클이 없어요."
        case .noSubscriptions: return "구독 중인 뉴스레터가 없어요."
        case .requireSignUp: return "회원이 되면 뉴스레터를\n간편하게 모아볼 수 있어요!"
        }
    }

    var subTitle: String {
        switch self {
        case .noArticles: return "구독 신청 이후 수신된 아티클만 볼 수 있어요."
        case .noSubscriptions: return "뉴스레터를 구독하면\n발행일에 맞춰 여기에 배달해드려요."
        case .requireSignUp: return ""
        }
    }

    var buttonTitle: String {
        switch self {
        case .noArticles:
            let weekday = Calendar.current.component(.weekday, from: Date())
            let weekdayString = Self.localizedWeekday(weekday)
            return "\(weekdayString)에 발행되는 뉴스레터 보기"
        case .noSubscriptions:
            return "내게 필요한 뉴스레터 추천받기"
        case .requireSignUp:
            return "회원가입"
        }
    }

    var showLoginOption: Bool {
        switch self {
        case .requireSignUp: return true
        default: return false
        }
    }

    private static func localizedWeekday(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "일요일"
        case 2: return "월요일"
        case 3: return "화요일"
        case 4: return "수요일"
        case 5: return "목요일"
        case 6: return "금요일"
        case 7: return "토요일"
        default: return ""
        }
    }
}



public struct NoDataView: View {
    let type: NoDataType
    let buttonAction: () -> Void
    let loginAction: (() -> Void)?
    let refreshAction: (() -> Void)?

    public init(
        type: NoDataType,
        buttonAction: @escaping () -> Void,
        loginAction: (() -> Void)? = nil,
        refreshAction: (() -> Void)? = nil
    ) {
        self.type = type
        self.buttonAction = buttonAction
        self.loginAction = loginAction
        self.refreshAction = refreshAction
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    refreshAction?()
                }) {
                    HStack(spacing: 0) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .foregroundStyle(Color.primaryNormal)

                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                            .padding(.leading, 4)
                    }
                }
                .padding(.top, 14)
                .padding(.trailing, 16)
            }

            Image(asset: type.imageName)
                .resizable()
                .frame(width: 280, height: 280)
                .padding(.top, 24)

            Text(type.title)
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "161616"))
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            if !type.subTitle.isEmpty {
                Text(type.subTitle)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "565656"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Button(action: buttonAction) {
                Text(type.buttonTitle)
                    .font(.hanSansNeo(14, .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            if type.showLoginOption {
                HStack {
                    Text("이미 계정이 있나요?")
                        .font(.hanSansNeo(14, .regular))
                        .foregroundColor(.gray)
                    Button(action: {
                        loginAction?()
                    }) {
                        Text("로그인")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(Color.primaryNormal)
                            .underline()
                    }
                }
                .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F5F5F7"))
    }
}
