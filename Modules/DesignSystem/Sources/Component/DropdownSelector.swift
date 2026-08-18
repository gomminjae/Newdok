//
//  DropdownSelector.swift
//  DesignSystem
//
//  Created by 권민재 on 4/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI

public struct DropdownOption: Hashable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }

    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
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
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(isSelected ? Color.primaryBgLight : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
        .shadow(color: Color.captionDark.opacity(0.12), radius: 20, x: 0, y: 0)
    }
}

/// 오버레이 방식 드롭다운 — 펼쳐도 아래 레이아웃이 밀리지 않고 옵션 리스트가 위에 뜬다.
public struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption?
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    var selectedKey: String?
    private let buttonHeight: CGFloat = 48

    public init(
        placeholder: String,
        options: [DropdownOption],
        onOptionSelected: ((_ option: DropdownOption) -> Void)? = nil,
        selectedKey: String? = nil
    ) {
        self.placeholder = placeholder
        self.options = options
        self.onOptionSelected = onOptionSelected
        self.selectedKey = selectedKey
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
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
                        .foregroundColor(Color.captionStrong)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 4).fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(shouldShowDropdown ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if shouldShowDropdown {
                Dropdown(options: self.options, selectedKey: selectedKey, onOptionSelected: { option in
                    shouldShowDropdown = false
                    selectedOption = option
                    self.onOptionSelected?(option)
                })
                .offset(y: buttonHeight + 8)
            }
        }
        .frame(height: buttonHeight, alignment: .top)
        .zIndex(1)
    }
}
