//
//  TermsOfUseView.swift
//  Mypage
//
//  Created by 권민재 on 5/21/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import WebKit
import Shared

public struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    private let termsURL = "https://newdok.notion.site/18aacf9713bc427a850ae8da92b69087?pvs=4"

    public var body: some View {
        VStack(spacing: 0) {
            WebView(urlString: termsURL)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .enableSwipeBack()
        .toolbar {
            // ⬅️ Back 버튼
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            // 📌 중앙 타이틀
            ToolbarItem(placement: .principal) {
                Text("이용약관")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}
