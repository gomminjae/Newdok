//
//  BirthYearDropdown.swift
//  Signup
//
//  Created by 권민재 on 4/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI

struct BirthYearDropdown: View {
    @Binding var selectedYear: String
    let years: [String] = (1990...2005).reversed().map { "\($0)" }

    var body: some View {
        Menu {
            ForEach(years, id: \.self) { year in
                Button(year) {
                    selectedYear = year
                }
            }
        } label: {
            HStack {
                Text(selectedYear)
                    .foregroundColor(selectedYear == nil ? Color.gray : Color.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 48)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}
