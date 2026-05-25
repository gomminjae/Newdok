//
//  BookmarkEmptyView 2.swift
//  Bookmark
//
//  Created by 권민재 on 5/14/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct BookmarkGuestView: View {
    var onLogin: () -> Void
    
    init(onLogin: @escaping () -> Void) {
        self.onLogin = onLogin
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: DesignSystemAsset.emptybookmark)
                .resizable()
                .frame(width: 280, height: 280)
                .padding(.bottom, 24)
                .padding(.top, 20)
            
            Text("저장한 아티클이 없어요.")
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color.captionHeavy)
                .padding(.bottom, 4)
            HStack(spacing: 0) {
                Text("로그인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.primaryNormal)
                    .underline()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onLogin()
                    }
                    .accessibilityLabel("로그인")
                    .accessibilityIdentifier("bookmark_guest_login")
                    .accessibilityAddTraits(.isButton)
                Text(" 후 다시 보고 싶은 아티클을 저장해보세요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
            }
            Spacer()
        }
        .background(.clear)
    }
}
