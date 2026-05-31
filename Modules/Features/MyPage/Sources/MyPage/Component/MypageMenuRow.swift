//
//  MypageMenuRow.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI
import DesignSystem

struct MypageMenuRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .font(.hanSansNeo(16, .medium))
                    .foregroundStyle(Color.captionStrong)
                Spacer()
                Image(asset: DesignSystemAsset.lineRight)
                    .foregroundColor(Color.captionNeutral)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 0)
            .frame(height: 48)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
