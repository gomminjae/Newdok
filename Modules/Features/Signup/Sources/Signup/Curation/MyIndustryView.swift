//
//  MyIndustryView.swift
//  Signup
//
//  Created by 권민재 on 4/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct MyIndustryView: View {
    
    let industryOptions: [DropdownOption] = [
            DropdownOption(key: "1", value: "IT · 게임 · 통신"),
            DropdownOption(key: "2", value: "F&B"),
            DropdownOption(key: "3", value: "건설"),
            DropdownOption(key: "4", value: "광고"),
            DropdownOption(key: "5", value: "교육")
        ]
    
    @ObservedObject private var viewModel: SignupViewModel
    
    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    
    var body: some View {
        VStack(alignment: .leading) {
            Text("종사 중인 산업을\n선택해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top,24)
            Text("선택하신 산업과 관련된 뉴스레터를 찾아드려요")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top,8)
            
            Text("종사산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top,42)
            
            DropdownSelector(placeholder: "산업군을 선택하세요", options: industryOptions)
                .padding(.top,8)
            
            Spacer()
            
            Button(action: viewModel.goToNextStep) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(.white)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
            .padding(.bottom, 20)
            
            
        }
        .padding(.horizontal, 24)
    }
}

//#Preview {
//    MyIndustryView()
//}
