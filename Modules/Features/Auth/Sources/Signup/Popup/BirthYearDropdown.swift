//
//  BirthYearDropdown.swift
//  Signup
//
//  Created by 권민재 on 4/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct DropdownOption: Hashable {
    let key: String
    let value: String

    static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var isSelected: Bool = false
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(isSelected ? Color.primaryNormal : Color.black)
                Spacer()
            }
        }
        .frame(height: 48)
        .padding(.horizontal, 16)
        .background(isSelected ? Color(hex: "#E9EFFA") : Color.clear)
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var selectedKey: String?
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(
                        option: option, 
                        isSelected: selectedKey == option.key,
                        onOptionSelected: self.onOptionSelected
                    )
                }
            }
        }
        .frame(height: 240)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(color: Color(hex: "#191919").opacity(0.12), radius: 20, x: 0, y: 0)
        // 보더 제거하고 그림자 추가
    }
}

struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption?
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    var selectedKey: String?
    private let buttonHeight: CGFloat = 48

    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text({
                    if let selectedKey = selectedKey, let selectedOption = options.first(where: { $0.key == selectedKey }) {
                        return selectedOption.value
                    } else if let selectedOption = selectedOption {
                        return selectedOption.value
                    } else {
                        return placeholder
                    }
                }())
                .font(.hanSansNeo(14, .medium))
                .foregroundColor({
                    if let selectedKey = selectedKey, let _ = options.first(where: { $0.key == selectedKey }) {
                        return .black
                    } else if selectedOption != nil {
                        return .black
                    } else {
                        return .gray
                    }
                }())

                Spacer()

                Image(asset: self.shouldShowDropdown ? DesignSystemAsset.lineUp : DesignSystemAsset.lineDown)
                    .foregroundColor(Color(hex: "#363636"))
            }
        }
        .frame(height: 48)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(shouldShowDropdown ? Color.primaryNormal : Color(hex: "#DADADA"), lineWidth: 1)
        )
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 10)
                    Dropdown(options: self.options, selectedKey: selectedKey, onOptionSelected: { option in
                        shouldShowDropdown = false
                        selectedOption = option
                        self.onOptionSelected?(option)
                    })
                }
            }, alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 5).fill(Color.white)
        )
        .zIndex(1)
    }
}

struct DropdownSelector_Previews: PreviewProvider {
    @State private static var address: String = ""

    static var uniqueKey: String {
        UUID().uuidString
    }

    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: "Sunday"),
        DropdownOption(key: uniqueKey, value: "Monday"),
        DropdownOption(key: uniqueKey, value: "Tuesday"),
        DropdownOption(key: uniqueKey, value: "Wednesday"),
        DropdownOption(key: uniqueKey, value: "Thursday"),
        DropdownOption(key: uniqueKey, value: "Friday"),
        DropdownOption(key: uniqueKey, value: "Saturday")
    ]

    static var previews: some View {
        VStack(spacing: 20) {
            DropdownSelector(
                placeholder: "선택",
                options: options,
                onOptionSelected: { _ in
                })
            .padding(.horizontal)
            .zIndex(1)
        }
    }
}
