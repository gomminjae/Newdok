//
//  EditProfileView.swift
//  Mypage
//
//  Created by 권민재 on 5/8/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared
import Foundation
import Combine
import PopupView

public struct EditProfileView: View {
    
    @AppStorage("nickname") private var nickname: String = ""
    @State private var userInfo: UserInfo? = nil
    @State private var industryId: Int? = nil
    @State private var showEditInterest = false

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter

    @FocusState private var isTextFieldFocused: Bool // ✅ 포커스 상태 추가

    @ObservedObject private var viewModel: MypageViewModel
    
    
    
    

    public init(viewModel: MypageViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("등록하신 정보에 맞춰\n뉴스레터를 추천해드려요")
                .font(.hanSansNeo(18, .bold))
                .padding(.top, 24)
                .padding(.bottom, 40)
            
            // 닉네임
            NavigationLink {
                EditNicknameView(nickname: $nickname, viewModel: viewModel)
                    .environmentObject(router)
            } label: {
                EditableRow(title: "닉네임", text: viewModel.user?.nickname ?? "")
            }

            // 종사산업
            NavigationLink {
                EditIndustryView(viewModel: viewModel)
                    .environmentObject(router)
            } label: {
                EditableRow(
                    title: "종사산업",
                    text: viewModel.user?.industryId
                        .flatMap { SelectableItemStore.shared.name(for: $0, in: .industry) } ?? "",
                    placeholder: "산업군을 선택해주세요."
                )
            }

            // 관심사
            if let interests = viewModel.user?.interests, !interests.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("관심사")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#565656"))

                    let interestNames = interests.compactMap {
                        SelectableItemStore.shared.name(for: $0.id, in: .interest)
                    }

                    Wrap(tags: interestNames, onAdd: {
                        showEditInterest = true
                    })
                    //.frame(maxWidth: .infinity, alignment: .leading)

                    NavigationLink(destination: EditInterestView(viewModel: viewModel), isActive: $showEditInterest) {
                        EmptyView()
                    }
                    .hidden()
                }
            } else {
                NavigationLink {
                    EditInterestView(viewModel: viewModel).environmentObject(router)
                } label: {
                    EditableRow(
                        title: "관심사",
                        text: "",
                        placeholder: "관심사를 선택해주세요."
                    )
                }
            }

            Spacer()
        }
        .onAppear {
            Task {
                await viewModel.fetchuserInfo()
            }
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("프로필 편집")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextFieldFocused = false
                }
                .foregroundStyle(Color.primaryNormal)
                .font(.hanSansNeo(17, .medium))
            }
        }
        .hideKeyboardOnTap()
        .popup(isPresented: $viewModel.shownicknameToast) {
            ToastView(message: "닉네임이 변경되었습니다.")
                .padding(.bottom, 106)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .popup(isPresented: $viewModel.showIndustryToast) {
            ToastView(message: "관심사가 변경 되었습니다.")
                .padding(.bottom, 106)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .popup(isPresented: $viewModel.showInterestToast) {
            ToastView(message: "닉네임이 변경되었습니다.")
                .padding(.bottom, 106)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        
        
    }
}


struct EditableRow: View {
    let title: String
    let text: String
    var placeholder: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? Color(hex: "#969696") : Color(hex: "#565656"))
                    .font(.hanSansNeo(14,.medium))
                Spacer()
                Image(asset: DesignSystemAsset.lineEdit)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "#363636"))
            }
            .padding()
            .frame(height: 48)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "dadada"))
            }
        }
    }
}
