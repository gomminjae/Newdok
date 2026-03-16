//
//  MyIndustryView.swift
//  Signup
//
//  Created by 권민재 on 4/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

struct MyIndustryView: View {
    let industryOptions: [DropdownOption] = SelectableItemStore.shared.industries.map {
        DropdownOption(key: "\($0.id)", value: $0.name)
    }

    @ObservedObject private var viewModel: SignupViewModel
    
    init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("종사 중인 산업을\n선택해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)
            Text("선택하신 산업과 관련된 뉴스레터를 찾아드려요")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.top, 8)
            
            Text("종사산업")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .padding(.top, 42)
            
            DropdownSelector(
                placeholder: "산업군을 선택하세요", 
                options: industryOptions, 
                onOptionSelected: { selected in
                    viewModel.myIndustry = selected.key
                }, selectedKey: viewModel.myIndustry.isEmpty ? nil : viewModel.myIndustry
            )

            Spacer()
            
            Button(action: viewModel.goToNextStep) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .foregroundColor(viewModel.myIndustry == "" ? Color.grayLight : .white)
                    .background(viewModel.myIndustry == "" ? Color.lineNeutral : Color.primaryNormal)
                    .cornerRadius(4)
            }
            .disabled(viewModel.myIndustry == "")
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
    }
}

// #Preview {
//    MyIndustryView()
// }
