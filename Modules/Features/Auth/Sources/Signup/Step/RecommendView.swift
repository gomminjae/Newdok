//
//  RecommendView.swift
//  Signup
//
//  Created by 권민재 on 4/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct RecommendView: View {
    
    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("뉴스레터 추천을 위해\n\(viewModel.nickname)님에 대해 \n더 알려주세요")
                .font(.hanSansNeo(20,.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top,24)
            Text("종사 산업과 관심사를 선택하면,\n내게 도움이 될 뉴스레터를 만나볼 수 있어요!")
                .font(.hanSansNeo(14,.medium))
                .foregroundStyle(Color(hex: "#565656"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top,8)
            Image(asset: DesignSystemAsset.nologin)
                .resizable()
                .frame(width: 280,height: 280)
                .frame(maxWidth: .infinity)
                .padding(.top,32)
            
            Spacer()

            // 다음 버튼
            Button(action: viewModel.goToNextStep) {
                Text("뉴스레터 추천받기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.white)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            
            
        }
    }
}

