//
//  ProfileInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI


enum NickNameValidationError: Error {
    case tooLong
    case containsSpecialCharacters
    
    var message: String {
        switch self {
        case .tooLong:
            return "닉네임은 최대 12자까지 입력할 수 있습니다."
        case .containsSpecialCharacters:
            return "특수문자는 사용할 수 없습니다."
        }
    }
}



struct ProfileInputView: View {
    
    @State private var nickName: String = ""
    @State private var birthYear: String = ""
    @State private var selectedGender: String? = nil
    
    @State private var isValidNickName: NickNameValidationError? = nil
    
    var nextStep: () -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("프로필 설정을 위해\n회원 정보를 입력해주세요.")
                .font(.title3)
                .bold()
        
            Text("닉네임")
                .font(.headline)
            
            TextField("12자 이내, 특수문자 사용 불가", text: $nickName)
                .padding(.leading, 16)
                .onChange(of: nickName) {
                    isValidNickName = isValidInput(nickName)
                }
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            
            if let error = isValidNickName {
                Text(error.message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

          
            Text("출생연도")
                .font(.headline)
            BirthYearDropdown()

            Text("출생연도는 뉴스레터 추천에 활용돼요.")
                .font(.footnote)
                .foregroundColor(.gray)

         
            Text("성별")
                .font(.headline)
            HStack(spacing: 8) {
                GenderButton(title: "남자", isSelected: selectedGender == "남자") {
                    selectedGender = "남자"
                }
                
                GenderButton(title: "여자", isSelected: selectedGender == "여자") {
                    selectedGender = "여자"
                }
            }

            Text("성별은 뉴스레터 추천에 활용돼요.")
                .font(.footnote)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    
    
    func isValidInput(_ nickName: String) -> NickNameValidationError? {
        if nickName.count > 12 {
            return .tooLong
        }
        let specialCharacterSet = CharacterSet.alphanumerics.inverted
        if nickName.rangeOfCharacter(from: specialCharacterSet) != nil {
            return .containsSpecialCharacters
        }
        
        return nil
    }
}


struct GenderButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "#2866D3") : .gray)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color(hex: "#2866D3") : Color.gray, lineWidth: 1)
                )
                .cornerRadius(10)
        }
    }
}

#Preview {
    ProfileInputView(nextStep: {})
}

