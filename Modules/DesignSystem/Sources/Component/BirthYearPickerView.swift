//
//  BirthYearPickerView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//
import SwiftUI

struct BirthYearDropdown: View {
    @Binding var selectedYear: String?
    let years: [String] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        let minYear = currentYear - 14  // 14세 이상
        let maxYear = 1950  // 최대 연도
        
        return (maxYear...minYear).reversed().map { "\($0)" }
    }()

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
