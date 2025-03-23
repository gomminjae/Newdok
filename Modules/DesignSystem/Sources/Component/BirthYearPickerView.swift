//
//  BirthYearPickerView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//
import SwiftUI

public struct BirthYearDropdown: View {
    @Namespace private var animationNamespace
    @State private var isExpanded = false
    @State private var selectedYear: String? = nil
    let years = Array(1900...Calendar.current.component(.year, from: Date())).reversed()

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            dropdownButton()

            if isExpanded {
                dropdownList()
            }
        }
    }
    
    private func dropdownButton() -> some View {
        Button(action: {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(selectedYear ?? "선택")
                    .foregroundColor(selectedYear == nil ? .gray : .black)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
            .matchedGeometryEffect(id: "dropdown", in: animationNamespace)
        }
    }

    /// 🔹 드롭다운 리스트 UI
    private func dropdownList() -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(years, id: \.self) { year in
                        yearRow(year) // ✅ 함수로 분리하여 코드 정리
                    }
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .frame(height: 200)
        }
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    /// 🔹 개별 연도 항목 UI
    private func yearRow(_ year: Int) -> some View {
        Text("\(year)")
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selectedYear == "\(year)" ? Color.blue.opacity(0.2) : Color.white)
            .foregroundColor(selectedYear == "\(year)" ? .blue : .black)
            .contentShape(Rectangle()) // ✅ 터치 영역 확장
            .onTapGesture {
                withAnimation(.spring()) {
                    selectedYear = "\(year)"
                    isExpanded = false
                }
            }
            .matchedGeometryEffect(id: String(year), in: animationNamespace)
    }
}

#Preview {
    BirthYearDropdown()
}
