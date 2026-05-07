//
//  ProfileInputView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import AuthDomain
public struct ProfileInputView: View {
    @State private var nicknameError: NicknameValidationError?
    @State private var selectedBirthYear: String?
    @State private var isExpanded: Bool = false
    @State private var dropdownYPosition: CGFloat = 0
    @FocusState private var isNicknameFocused: Bool

    @ObservedObject private var viewModel: SignupViewModel

    let birthYearOptions: [DropdownOption] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        let minYear = currentYear - 14  // 14세 이상
        let maxYear = 1950  // 최대 연도

        return (maxYear...minYear).reversed().map {
            DropdownOption(key: "\($0)", value: "\($0)")
        }
    }()

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
        if !viewModel.birthYear.isEmpty {
            _selectedBirthYear = State(initialValue: viewModel.birthYear)
        }
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
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 42)
                        .padding(.bottom, 8)
                        .padding(.leading, 4)

                    HStack {
                        Image(asset: DesignSystemAsset.lineUser)
                            .renderingMode(.template)
                            .foregroundStyle(isNicknameFocused ? Color.captionStrong : Color.captionAssistive)
                        TextField("12자 이내, 특수문자 사용 불가", text: $viewModel.nickname)
                            .font(.hanSansNeo(14, .medium))
                            .focused($isNicknameFocused)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(viewModel.showNicknameError ? Color.errorBg : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                viewModel.showNicknameError
                                ? Color.errorNormal
                                : (isNicknameFocused ? Color.primaryNormal : Color.lineAlternative),
                                lineWidth: 1
                            )
                    )

                    // 에러 메시지
                    if viewModel.showNicknameError, let error = viewModel.nicknameValidationError {
                        Text(error.message)
                            .font(.footnote)
                            .foregroundStyle(Color.errorNormal)
                    } else if viewModel.showNicknameSuccess {
                        Text("사용 가능한 닉네임 입니다.")
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }

                    Text("출생연도")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.bottom, 8)
                        .padding(.leading, 4)
                        .padding(.top, 32)

                    Button(action: {
                        isNicknameFocused = false
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(selectedBirthYear ?? "선택")
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color.captionStrong)

                            Spacer()
                            Image(asset: isExpanded ? DesignSystemAsset.lineDown : DesignSystemAsset.lineUp)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isExpanded ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
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
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 8)

                    Text("성별")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionNeutral)
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
                        .foregroundStyle(Color.captionNeutral)
                        .padding(.top, 8)

                    Spacer()

                    Button(action: {
                        viewModel.goToNextStep()
                    }) {
                        Text("다음")
                            .font(.hanSansNeo(14, .bold))
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isProfileInputValid ? Color.primaryNormal : Color.lineNeutral)
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

                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isNicknameFocused = false
                        }
                        .foregroundStyle(Color.primaryNormal)
                        .font(.hanSansNeo(17, .medium))
                    }
                }

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
                                                .foregroundColor(item.value == selectedBirthYear ? .primaryNormal : Color.captionStrong)
                                                .font(.hanSansNeo(14, .medium))
                                            Spacer()
                                        }
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 20)
                                        .background(
                                            item.value == selectedBirthYear
                                                ? Color.primaryBgLight
                                                : Color.white
                                        )
                                    }
                                    .id(item.key)
                                }
                            }
                        }
                        .frame(height: 240)
                        .background(Color.white)
                        .cornerRadius(4)
                        .shadow(color: Color.captionDark.opacity(0.12), radius: 20, x: 0, y: 0)
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
                .font(.hanSansNeo(16, .medium))
                .foregroundColor(isSelected ? Color.primaryNormal : Color.captionAssistive)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.primaryNormal : Color.lineAlternative, lineWidth: 1)
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
        SignupFormatStyle.validateNickname(nickname)
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
