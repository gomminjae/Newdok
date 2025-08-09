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
    @State private var showEditInterest = false

    @EnvironmentObject private var router: AppRouter

    @FocusState private var isTextFieldFocused: Bool

    @EnvironmentObject private var viewModel: MypageViewModel

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("등록하신 정보에 맞춰\n뉴스레터를 추천해드려요")
                .font(.hanSansNeo(18, .bold))
                .padding(.top, 24)
                .padding(.bottom, 40)
                .allowsHitTesting(false)
            
            // MARK: 닉네임
            EditableRow(
                title: "닉네임",
                text: viewModel.user?.nickname ?? "",
                onEdit: {
                    router.push(.editNickname)
                }
            )
           
            // MARK: 종사산업
            let industryName = getIndustryName()
            EditableRow(
                title: "종사산업",
                text: industryName,
                placeholder: "산업군을 선택해주세요.",
                onEdit: {
                    router.push(.editIndustry)
                }
            )
            .padding(.top, 24)

            // MARK: 관심사
            if let interestSection = interestSectionView() {
                interestSection
                    .padding(.top, 24)
            } else {
                Button {
                    router.push(.editInterest)
                } label: {
                    EditableRow(
                        title: "관심사",
                        text: "",
                        placeholder: "관심사를 선택해주세요."
                    )
                }
                .padding(.top, 24)
            }

            Spacer()
        }
        .onAppear {
            Task { await viewModel.fetchuserInfo() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("RefreshProfile"))) { _ in
            Task { await viewModel.fetchuserInfo() }
        }
        .onChange(of: viewModel.showPasswordSuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "비밀번호가 변경되었습니다.")
                viewModel.showPasswordSuccess = false
            }
        }
        .onChange(of: viewModel.showPhoneNumberSuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "휴대폰 번호가 변경되었습니다.")
                viewModel.showPhoneNumberSuccess = false
            }
        }
        .onChange(of: viewModel.showNicknameSuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "닉네임이 변경되었습니다.")
                viewModel.showNicknameSuccess = false
            }
        }
        .onChange(of: viewModel.showIndustrySuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "종사산업이 변경되었습니다.")
                viewModel.showIndustrySuccess = false
            }
        }
        .onChange(of: viewModel.showInterestSuccess) { _, showToast in
            if showToast {
                NotificationCenter.default.post(name: .showToast, object: "관심사가 변경되었습니다.")
                viewModel.showInterestSuccess = false
            }
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.pop() } label: {
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTextFieldFocused = false }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
            }
        }
        .hideKeyboardOnTap()
        // TOAST
        .popup(isPresented: $viewModel.shownicknameToast) {
            ToastView(message: "닉네임이 변경되었습니다.")
                .padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut)
        }
        .popup(isPresented: $viewModel.showIndustryToast) {
            ToastView(message: "종사산업이 변경되었습니다.")
                .padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut)
        }
        .popup(isPresented: $viewModel.showInterestToast) {
            ToastView(message: "관심사가 변경되었습니다.")
                .padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut)
        }
    }

    // MARK: - Helper
    private func getIndustryName() -> String {
        guard let id = viewModel.user?.industryId else { return "" }
        return SelectableItemStore.shared.name(for: id, in: .industry) ?? ""
    }

    private func interestSectionView() -> AnyView? {
        guard let interests = viewModel.user?.interests, !interests.isEmpty else { return nil }
        
        let interestNames = interests.compactMap {
            SelectableItemStore.shared.name(for: $0.id, in: .interest)
        }
        let items = interestNames + ["+"]
        let rowCount = (items.count + 2) / 3

        let section = VStack(alignment: .leading, spacing: 8) {
            Text("관심사")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<rowCount, id: \.self) { row in
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { col in
                            let idx = row * 3 + col
                            if idx < items.count {
                                let item = items[idx]
                                if item == "+" {
                                    Button {
                                        router.push(.editInterest)
                                    } label: {
                                        Image(asset: DesignSystemAsset.linePlus)
                                            .renderingMode(.template)
                                            .foregroundColor(.primaryNormal)
                                            .frame(width: 32, height: 32)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.primaryNormal, lineWidth: 1)
                                            )
                                    }
                                } else {
                                    Text(item)
                                        .font(.hanSansNeo(13, .regular))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color(hex: "#DADADA"))
                                        )
                                        .allowsHitTesting(false)
                                }
                            } else {
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }

        return AnyView(section)
    }
}

// MARK: - 재사용 가능한 편집 행
struct EditableRow: View {
    let title: String
    let text: String
    var placeholder: String = ""
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .foregroundColor(text.isEmpty ? Color(hex: "#969696") : Color(hex: "#565656"))
                    .font(.hanSansNeo(14, .medium))
                Spacer()
                Button(action: { onEdit?() }) {
                    Image(asset: DesignSystemAsset.lineEdit)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "#363636"))
                }
            }
            .padding()
            .frame(height: 48)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "#DADADA"))
            }
        }
    }
}
