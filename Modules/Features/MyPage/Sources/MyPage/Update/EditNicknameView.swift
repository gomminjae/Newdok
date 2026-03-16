//
//  EditNicknameView.swift
//  Mypage
//
//  Created by 권민재 on 5/8/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Foundation
import Combine
import Shared
import Domain

public struct EditNicknameView: View {
    @Binding var nickname: String
    @State private var draftNickname: String
    @State private var validationState: ValidationState = .none
    @FocusState private var isFocused: Bool
    
    @EnvironmentObject private var viewModel: MypageViewModel
    @EnvironmentObject private var toast: ToastCenter
    @EnvironmentObject private var router: AppRouter
    
    public init(nickname: Binding<String>) {
        self._nickname = nickname
        self._draftNickname = State(initialValue: nickname.wrappedValue)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("닉네임")
                        .font(.hanSansNeo(14, .medium))
                    
                    TextField("닉네임을 입력해주세요", text: $draftNickname)
                        .padding()
                        .font(.hanSansNeo(14, .medium))
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    validationState == .invalidChar || validationState == .tooLong || validationState == .tooShort 
                                    ? Color.errorNormal 
                                    : isFocused ? .primaryNormal : Color.lineAlternative,
                                    lineWidth: 1
                                )
                        )
                        .focused($isFocused)
                        .onChange(of: draftNickname) { _, newValue in
                            validate(newValue)
                        }
                        .onTapGesture {
                            isFocused = true
                        }

                    if validationState != .none {
                        Text(validationState.message)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundColor(validationState.textColor)
                    }

                    Spacer().frame(height: 100) // 변경하기 버튼 여백 확보
                }
                .padding(20)
            }

            Button(action: {
                Task {
                    await viewModel.updateNickname(nickname: draftNickname)
                    await viewModel.fetchuserInfo()
                    nickname = draftNickname
                    // 먼저 화면을 닫고, 다음 프레임에서 토스트 노출(팝된 뷰에서 보이도록)
                    await MainActor.run { router.pop() }
                    // pop 이후에도 살아있는 전역 싱글톤을 통해 토스트 표시 (뷰 생명주기와 분리)
                    Task.detached { @MainActor in
                        try? await Task.sleep(nanoseconds: 150_000_000)
                        ToastCenter.shared.show("닉네임이 변경되었습니다.")
                    }
                }
            }) {
                Text("변경하기")
                    .font(.hanSansNeo(14, .bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isButtonEnabled ? Color.primaryNormal : Color.lineNeutral)
                    .foregroundColor(isButtonEnabled ? .white : Color.grayLight)
                    .cornerRadius(4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .disabled(!isButtonEnabled)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("닉네임 변경")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }

        .ignoresSafeArea(.keyboard)
        .onAppear {
            // 닉네임 필드에 자동 포커스
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    
    private var isButtonEnabled: Bool {
        return validationState == .valid && draftNickname != nickname
    }
    
    private func validate(_ text: String) {
        if text.count > 12 {
            validationState = .tooLong
        } else if text.count < 2 {
            validationState = .tooShort
        } else if text.contains(where: { "!@#$%^&*()[]{}:;<>,.?/~`+=|\\\"".contains($0) }) {
            validationState = .invalidChar
        } else {
            validationState = .valid
        }
    }
}

enum ValidationState {
    case none
    case tooShort
    case tooLong
    case invalidChar
    case valid

    var message: String {
        switch self {
        case .none: return "닉네임은 2자 이상 12자 이하로 입력해주세요."
        case .tooShort: return "2자 이상 입력해주세요."
        case .tooLong: return "12자 이하로 입력해주세요."
        case .invalidChar: return "특수문자는 사용할 수 없어요."
        case .valid: return "사용 가능한 닉네임입니다."
        }
    }

    var textColor: Color {
        switch self {
        case .valid: return .primaryNormal
        case .invalidChar, .tooLong, .tooShort: return Color.errorNormal
        case .none: return Color.captionAssistive
        }
    }

    var borderColor: Color {
        switch self {
        case .valid: return .primaryNormal
        case .invalidChar, .tooLong, .tooShort: return Color.errorNormal
        case .none: return Color.lineAlternative
        }
    }
}
