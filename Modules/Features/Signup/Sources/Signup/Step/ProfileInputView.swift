//
//  ProfileInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
public struct ProfileInputView: View {
    @State private var nicknameError: NickNameValidationError? = nil
    @State private var selectedBirthYear: String? = nil
    @State private var isExpanded: Bool = false
    @State private var dropdownYPosition: CGFloat = 0

    @ObservedObject private var viewModel: SignupViewModel

    let birthYearOptions: [DropdownOption] = (1990...2025).map {
        DropdownOption(key: "\($0)", value: "\($0)")
    }

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
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
                        .frame(height: 50)
                        .background(viewModel.showNicknameError ? Color(hex: "#FEE6E6") : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    viewModel.showNicknameError
                                    ? Color(hex: "#E32727")
                                    : Color.gray.opacity(0.5),
                                    lineWidth: 1
                                )
                        )

                    // 에러 메시지
                    if viewModel.showNicknameError, let error = viewModel.nicknameValidationError {
                        Text(error.message)
                            .font(.footnote)
                            .foregroundStyle(Color(hex: "#E32727"))
                    } else if viewModel.showNicknameSuccess {
                        Text("사용 가능한 닉네임 입니다.")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color(hex: "#2866D3"))
                    }

                    Text("출생연도")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.bottom, 8)
                        .padding(.leading, 4)
                        .padding(.top, 32)

                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedBirthYear ?? "선택")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color(hex: "363636"))

                            Spacer()
                            Image(asset: isExpanded ? DesignSystemAsset.lineDown : DesignSystemAsset.lineUp)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "C0C0C0"))
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            dropdownYPosition = geo.frame(in: .global).maxY
                                        }
                                    }
                            }
                        )
                    }

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
                        
                        GenderButton(title: "그외", isSelected: viewModel.gender == "그외") {
                            viewModel.gender = "그외"
                        }
                    }

                    Text("성별은 뉴스레터 추천에 활용돼요.")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color(hex: "#565656"))
                        .padding(.top, 8)

                    Spacer()

                    Button(action: {
                        viewModel.goToNextStep()
                    }) {
                        Text("다음")
                            .font(.hanSansNeo(14, .bold))
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isProfileInputValid ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .ignoresSafeArea(.keyboard)
                    .padding(.bottom, 20)
                    .contentShape(Rectangle())
                    .disabled(!viewModel.isProfileInputValid)
                }
                .padding(.horizontal, 24)
                .scrollDisabled(true)
                .ignoresSafeArea(.keyboard)

                if isExpanded {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(birthYearOptions, id: \.key) { item in
                                    Button {
                                        selectedBirthYear = item.value
                                        viewModel.birthYear = item.key
                                        isExpanded = false
                                    } label: {
                                        HStack {
                                            Text(item.value)
                                                .foregroundColor(item.value == selectedBirthYear ? .primaryNormal : Color(hex: "363636"))
                                                .font(.hanSansNeo(14, .medium))
                                            Spacer()
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 20)
                                        .background(
                                            item.value == selectedBirthYear
                                                ? Color.primaryNormal.opacity(0.1)
                                                : Color.white
                                        )
                                    }
                                    .id(item.key)
                                }
                            }
                        }
                        .frame(height: 240)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "C0C0C0"))
                                .background(Color.white)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(hex: "C0C0C0"))
                            
                        }
                    }
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .position(x: geometry.size.width / 2, y: dropdownYPosition + 24)
                    .zIndex(1)
                }
            }
        }
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
extension SignupViewModel {
    var isProfileInputValid: Bool {
           !nickname.isEmpty &&
           nicknameValidationError == nil &&
           !birthYear.isEmpty &&
           !gender.isEmpty
       }
    var nicknameValidationError: NicknameValidationError? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1자 이상 12자 이하
        if trimmed.isEmpty || trimmed.count > 12 {
            return .invalidLength
        }

        // 정규식으로 허용 문자만 검사 (한글, 영문, 숫자)
        let regex = "^[a-zA-Z0-9가-힣]+$"
        if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmed) {
            return .containsInvalidCharacters
        }

        return nil
    }


    var isNicknameValid: Bool {
        nicknameValidationError == nil
    }

    var showNicknameError: Bool {
        !nickname.isEmpty && nicknameValidationError != nil
    }

    var showNicknameSuccess: Bool {
        !nickname.isEmpty && nicknameValidationError == nil
    }
}
