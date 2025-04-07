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
    @ObservedObject private var viewModel: SignupViewModel
    @State private var nicknameError: NickNameValidationError? = nil
    
    var nextStep: () -> Void

    public init(viewModel: SignupViewModel, nextStep: @escaping () -> Void) {
        self.viewModel = viewModel
        self.nextStep = nextStep
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
                .padding(.leading, 16)
                .onChange(of: viewModel.nickname) { _ in
                    nicknameError = viewModel.validateNickname()
                }
                .frame(height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(nicknameError != nil ? Color.red : Color.gray.opacity(0.5), lineWidth: 1)
                )

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

            BirthYearDropdown()

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
        }
        .padding(.horizontal, 24)
        .navigationTitle("회원가입")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
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

//#Preview {
//    ProfileInputView(nextStep: {})
//}
//
