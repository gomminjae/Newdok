//
//  ProfileInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem


public enum NickNameValidationError: Error {
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



public struct ProfileInputView: View {
    
    @State private var nicknameError: NickNameValidationError? = nil
    

    @ObservedObject private var viewModel: SignupViewModel
    
    let birthYearOptions: [DropdownOption] = (1990...2025).reversed().map {
        DropdownOption(key: "\($0)", value: "\($0)")
    }
    
    public init(viewModel: SignupViewModel) {
            self.viewModel = viewModel
        }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("프로필 설정을 위해\n회원 정보를 입력해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)
            
            Text("닉네임")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 42)
                .padding(.bottom, 8)
                .padding(.leading, 4)
            
            TextField("12자 이내, 특수문자 사용 불가", text: $viewModel.nickname)
                .font(.hanSansNeo(14, .medium))
                .padding(.leading, 16)
            //                .onChange(of: viewModel.nickname) { _ in
            //                    nicknameError = viewModel.validateNickname()
            //                }
                .onSubmit {
                    nicknameError = viewModel.validateNickname()
                }
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(nicknameError != nil ? Color.red : Color.gray.opacity(0.5), lineWidth: 1)
                )
                .contentShape(Rectangle())
            
            if let error = nicknameError {
                Text(error.message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            
            Text("출생연도")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.bottom, 8)
                .padding(.leading, 4)
                .padding(.top, 32)
            
           DropdownSelector(placeholder: "선ㅌ", options: birthYearOptions)
                .frame(height: 48)
            
            Text("출생연도는 뉴스레터 추천에 활용돼요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 8)
            
            Text("성별")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 32)
            
            HStack(spacing: 8) {
                GenderButton(title: "남자", isSelected: viewModel.gender == "남자") {
                    viewModel.gender = "남자"
                }
                
                GenderButton(title: "여자", isSelected: viewModel.gender == "여자") {
                    viewModel.gender = "여자"
                }
            }
            
            Text("성별은 뉴스레터 추천에 활용돼요.")
                .font(.hanSansNeo(12, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 8)
            
            Spacer()
            Button(action: {
                print("중복검사")
                viewModel.goToNextStep()
            }) {
                Text("다음")
                    .font(.hanSansNeo(14, .bold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isIDAvailable ?? false ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            .ignoresSafeArea(.keyboard)
            .padding(.bottom, 20)
            .contentShape(Rectangle())
        }
        .scrollDisabled(true)
        .padding(.horizontal, 24)
        .ignoresSafeArea(.keyboard)
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
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color(hex: "#2866D3") : Color.gray, lineWidth: 1)
                )
        }
    }
}
