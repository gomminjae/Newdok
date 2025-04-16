//
//  NoDataView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//

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
        case .noArticles: return "수요일에 발행되는 뉴스레터 보기"
        case .noSubscriptions: return "내게 필요한 뉴스레터 추천받기"
        case .requireSignUp: return "회원가입"
        }
    }

    var showLoginOption: Bool {
        switch self {
        case .requireSignUp: return true
        default: return false
        }
    }
}


public struct NoDataView: View {
    let type: NoDataType
    let buttonAction: () -> Void
    let loginAction: (() -> Void)? // 로그인 버튼이 필요한 경우만 사용
    
    
    public init(
        type: NoDataType,
        buttonAction: @escaping () -> Void,
        loginAction: (() -> Void)? = nil
    ) {
        self.type = type
        self.buttonAction = buttonAction
        self.loginAction = loginAction
    }
    

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer()
                Button(action: {
                    print("새로고침")
                }) {
                    HStack(spacing: 0) {
                        Image(asset: DesignSystemAsset.refresh)
                            .foregroundStyle(Color.primaryNormal)
                        Text("새로고침")
                            .font(.hanSansNeo(12, .regular))
                            .foregroundStyle(Color.primaryNormal)
                            .padding(.leading, 4)
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 28)
            }

    
            Image(asset: type.imageName)
                .resizable()
                .frame(width: 280, height: 280)
                .padding(.top, 24)

          
            Text(type.title)
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 24)

         
            if !type.subTitle.isEmpty {
                Text(type.subTitle)
                    .font(.hanSansNeo(14, .regular))
                    .padding(.top, 4)
            }

          
            Button(action: buttonAction) {
                Text(type.buttonTitle)
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

          
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
        .background(Color(hex: "F5F5F7"))
    }
}

#Preview {
    NoDataView(type: .requireSignUp) {
        print("뉴스레터 보기 클릭")
    } loginAction: {}
}
