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

public struct EditProfileView: View {
    
    @AppStorage("nickname") private var nickname: String = ""
    @State private var userInfo: UserInfo? = nil

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("등록하신 정보에 맞춰\n뉴스레터를 추천해드려요")
                .font(.hanSansNeo(18, .bold))
                .padding(.top, 24)
                .padding(.bottom, 40)

            NavigationLink {
                EditNicknameView(nickname: $nickname)
            } label: {
                EditableRow(title: "닉네임", text: userInfo?.nickname ?? "")
            }

            EditableRow(
                title: "종사산업",
                text: userInfo?.industryId
                    .flatMap { SelectableItemStore.shared.name(for: $0, in: .industry) } ?? "",
                placeholder: "산업군을 선택해주세요."
            )

            EditableRow(
                title: "관심사",
                text: userInfo?.interestIds
                    .map { SelectableItemStore.shared.name(for: $0, in: .interest) }
                    .joined(separator: ", ") ?? "",
                placeholder: "관심사를 선택해주세요."
            )

            Spacer()
        }
        .onAppear {
            userInfo = UserInfoStore.shared.load()
        }
        .padding(.horizontal, 20)
        .navigationTitle("프로필 편집")
        .navigationBarTitleDisplayMode(.inline)
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
