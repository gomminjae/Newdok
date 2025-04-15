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
        DropdownOption(key: "1", value: "모든 산업"),
        DropdownOption(key: "2", value: "IT・게임・통신"),
        DropdownOption(key: "3", value: "F&B"),
        DropdownOption(key: "4", value: "건설・건축"),
        DropdownOption(key: "5", value: "광고"),
        DropdownOption(key: "6", value: "교육"),
        DropdownOption(key: "7", value: "금융・부동산"),
        DropdownOption(key: "8", value: "문화・예술・엔터테인먼트"),
        DropdownOption(key: "9", value: "미디어・출판"),
        DropdownOption(key: "10", value: "생산・제조"),
        DropdownOption(key: "11", value: "생활・서비스"),
        DropdownOption(key: "12", value: "유통・무역"),
        DropdownOption(key: "13", value: "의료"),
        DropdownOption(key: "14", value: "패션"),
        DropdownOption(key: "15", value: "자영업"),
        DropdownOption(key: "16", value: "기타")
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
            
            DropdownSelector(placeholder: "산업군을 선택하세요", options: industryOptions, onOptionSelected: { selected in
                viewModel.myIndustry = selected.key
            })

            
            Spacer()
            
            Button(action: viewModel.goToNextStep) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(viewModel.myIndustry == "" ? Color(hex: "BDBDBD") : .white)
                    .background(viewModel.myIndustry == "" ? Color(hex: "EBEBEB") : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.myIndustry == "")
            .padding(.bottom, 20)
            
            
            
        }
        .padding(.horizontal, 24)
    }
}

//#Preview {
//    MyIndustryView()
//}
