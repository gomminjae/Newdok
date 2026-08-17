//
//  TermsMenuView.swift
//  Mypage
//
//  Created by 권민재 on 5/21/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import Shared

public struct TermsMenuView: View {
    private let onBack: () -> Void

    public init(onBack: @escaping () -> Void) {
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 12) {
            NavigationLink {
                WebLinkView(title: "서비스 이용약관", urlString: "https://newdok.notion.site/18aacf9713bc427a850ae8da92b69087?pvs=4")
            } label: {
                HStack {
                    Text("서비스 이용약관")
                        .foregroundColor(Color.captionStrong)
                        .font(.hanSansNeo(16, .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .frame(height: 48)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            NavigationLink {
                WebLinkView(title: "개인정보 처리방침", urlString: "https://newdok.notion.site/82ef5aea46d84623b7b19bb951b6043c?pvs=4")
            } label: {
                HStack {
                    Text("개인정보 처리방침")
                        .foregroundColor(Color.captionStrong)
                        .font(.hanSansNeo(16, .medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .frame(height: 48)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onBack()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("약관 및 정책")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }
}

public struct WebLinkView: View {
    public let title: String
    public let urlString: String
    @Environment(\.dismiss) private var dismiss

    public init(title: String, urlString: String) {
        self.title = title
        self.urlString = urlString
    }

    public var body: some View {
        WebView(urlString: urlString)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(asset: DesignSystemAsset.back)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                }
            }
    }
}
