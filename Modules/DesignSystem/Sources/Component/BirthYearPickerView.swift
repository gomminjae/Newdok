//
//  BirthYearPickerView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//
import SwiftUI

struct BirthYearDropdown: View {
    @Binding var selectedYear: String?
    let years: [String] = (2025...1900).reversed().map { "\($0)" }

    var body: some View {
        Menu {
            ForEach(years, id: \.self) { year in
                Button(year) {
                    selectedYear = year
                }
            }
        } label: {
            HStack {
                Text(selectedYear ?? "선택")
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


