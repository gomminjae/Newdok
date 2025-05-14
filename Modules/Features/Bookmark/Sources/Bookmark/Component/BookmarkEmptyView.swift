//
//  BookmarkEmptyView.swift
//  Bookmark
//
//  Created by 권민재 on 5/2/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem

struct BookmarkEmptyView: View {
    
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: DesignSystemAsset.emptybookmark)
                .padding(.bottom, 24)
                .padding(.top, 20)
            
            Text("저장한 아티클이 없어요.")
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "#161616"))
                .padding(.bottom, 4)
            
            Text("북마크를 눌러 다시 보고싶은 아티클을 저장해보세요.")
                .font(.hanSansNeo(14,.medium))
                .foregroundStyle(Color(hex: "#565656"))
            Spacer()
        }
        .background(.clear)
    }
}

