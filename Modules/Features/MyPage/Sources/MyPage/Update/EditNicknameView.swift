//
//  EditNicknameView.swift
//  Mypage
//
//  Created by 권민재 on 5/8/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import DesignSystem

public struct EditNicknameView: View {
    
    @Binding var nickname: String
    @State private var draftNickname: String
    @State private var validationState: ValidationState = .none
    @FocusState private var isFocused: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    
    public init(nickname: Binding<String>) {
        self._nickname = nickname
        self._draftNickname = State(initialValue: nickname.wrappedValue)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("닉네임")
                .font(.hanSansNeo(14, .medium))
            
            TextField("", text: $draftNickname)
                .padding()
                .font(.hanSansNeo(14, .medium))
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            isFocused ? .primaryNormal : validationState.borderColor,
                            lineWidth: 1
                        )
                )
                .focused($isFocused)
                .onChange(of: draftNickname, perform: validate)

            Text(validationState.message)
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(validationState.textColor)
            
            Spacer()
            
            Button(action: {
                nickname = draftNickname
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .padding(20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.back)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
            }
            ToolbarItem(placement: .principal) {
                Text("닉네임 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        
    }
    
    func validate(_ text: String) {
        if text.count > 12 {
            validationState = .tooLong
        } else if text.contains(where: { "!@#$%^&*()[]{}:;<>,.?/~`+=|\\\"".contains($0) }) {
            validationState = .invalidChar
        } else if text.count > 1 {
            validationState = .valid
        } else {
            validationState = .none
        }
    }
}


enum ValidationState {
    case none
    case tooLong
    case invalidChar
    case valid
    
    var message: String {
        switch self {
        case .none: return "닉네임은 12자 이내로 입력해주세요."
        case .tooLong: return "12자 이하로 입력해주세요."
        case .invalidChar: return "특수문자는 사용할 수 없어요."
        case .valid: return "사용 가능한 닉네임입니다."
        }
    }
    
    var textColor: Color {
        switch self {
        case .valid: return .primaryNormal
        case .invalidChar, .tooLong: return Color(hex: "E32727")
        case .none: return .gray
        }
    }
    
    var borderColor: Color {
        switch self {
        case .valid: return .primaryNormal
        case .invalidChar, .tooLong: return Color(hex: "E32727")
        case .none: return Color(hex: "DADADA")
        }
    }
}
