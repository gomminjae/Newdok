//
//  VersionView.swift
//  MyPage
//
//  Created by 권민재 on 5/14/25.
//

import SwiftUI
import DesignSystem
import Shared

public struct VersionView: View {
    @EnvironmentObject private var router: AppRouter
    
    public init() {}
    
    // 앱 버전 정보 가져오기
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("버전")
                    .font(.hanSansNeo(18, .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // 오른쪽 여백을 위한 투명 버튼
                Button {} label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.clear)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // 버전 정보
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("현재 버전")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                    
                    Text(appVersion)
                        .font(.hanSansNeo(20, .bold))
                        .foregroundColor(Color(hex: "#161616"))
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .enableSwipeBack()
    }
} 