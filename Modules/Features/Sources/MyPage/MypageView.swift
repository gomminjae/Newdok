//
//  ArticleView.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI

public struct MypageView: View {
    
    public init() {}
    public var body: some View {
        // 스크롤 가능하도록 ScrollView 사용
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - 상단 프로필 영역
                VStack(alignment: .leading, spacing: 8) {
                    
                    // 1) 닉네임
                    Text("닉네임최대열자열두자열")
                        .font(.hanSansNeo(16,.bold))
                    
                    // 2) "구독이메일 ?" 라벨
                    HStack(spacing: 4) {
                        Text("구독이메일")
                            .font(.hanSansNeo(14,.medium))
                            .foregroundColor(Color(hex: "#565656"))
                        
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#565656"))
                    }
                    
                    // 3) 이메일 주소 (복사 아이콘 + 이메일)
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                        Text("newdok001@newdok.tbd")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                    
                    // 4) 프로필 편집 버튼
                    Button(action: {
                        // TODO: 프로필 편집 액션
                    }) {
                        Text("프로필 편집")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20) // 좌우 여백
                
                // MARK: - 서비스 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("서비스")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    // 각 메뉴 항목
                    NavigationLink(destination: Text("계정 관리 화면")) {
                        settingRow(title: "계정 관리")
                    }
                    NavigationLink(destination: Text("알림 설정 화면")) {
                        settingRow(title: "알림 설정")
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - 고객센터 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("고객센터")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: Text("FAQ 화면")) {
                        settingRow(title: "FAQ")
                    }
                    NavigationLink(destination: Text("서비스 피드백 화면")) {
                        settingRow(title: "서비스 피드백")
                    }
                    NavigationLink(destination: Text("약관 및 정책 화면")) {
                        settingRow(title: "약관 및 정책")
                    }
                    NavigationLink(destination: Text("버전 화면")) {
                        settingRow(title: "버전")
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 40)
            }
            .padding(.top, 20)  // 전체 상단 여백
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true) // 상단 네비게이션 바 숨김(필요시)
    }
    
    // 공용으로 쓸 셋팅 항목 뷰
    @ViewBuilder
    private func settingRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(height: 44)
    }
}

// 미리보기
#Preview {
    NavigationView {
        MypageView()
    }
}
