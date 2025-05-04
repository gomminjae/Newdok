//
//  BookmarkView.swift
//  Bookmark
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//


import SwiftUI
import DesignSystem

public struct BookmarkView: View {
    @State private var selectedCategory: String = "전체"
    @State private var sortOrder: String = "추가순"
    
    public let interests: [String: String] = [
        "1": "경제・시사・상식",
        "2": "비즈니스",
        "3": "과학・기술",
        "4": "트렌드",
        "5": "재테크",
        "6": "콘텐츠",
        "7": "라이프스타일",
        "8": "취미・자기계발",
        "9": "건강・의학",
        "10": "멘탈케어",
        "11": "푸드・드링크",
        "12": "자연・환경",
        "13": "리빙・인테리어",
        "14": "미술・디자인・전시",
        "15": "음악",
        "16": "게임",
        "17": "콘서트・공연",
        "18": "문화",
        "19": "문학・도서",
        "20": "언어",
        "21": "영화",
        "22": "지역・여행",
        "23": "가족",
        "24": "쇼핑",
        "25": "반려동물",
        "26": "사회공헌"
    ]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView()
            
            categoryFilter
            sortInfo
            
            if sampleArticles.isEmpty {
                VStack {
                    BookmarkEmptyView()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .background(Color(hex: "#F5F5F7"))
                    Spacer()
                }
                .background(Color(hex: "#F5F5F7"))
            } else {
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 24) {
                        section(month: "2023년 11월", articles: sampleArticles)
                        section(month: "2023년 10월", articles: sampleArticles)
                    }
                }
                .background(Color(hex: "#F5F5F7"))
            }
        }
        .background(.white)
    }
    
    private func headerView() -> some View {
        HStack {
            Text("북마크함")
                .font(.hanSansNeo(18, .bold))
            
            Spacer()
            
            Button(action: {}) {
                Image(asset: DesignSystemAsset.lineSearch)
            }
            .padding(.trailing, 12)
            
            Button(action: {}) {
                Image(asset: DesignSystemAsset.lineBell)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    private var categoryFilter: some View {
        let sortedCategories = ["전체"] + interests.values.sorted()

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(sortedCategories, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.hanSansNeo(13, .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedCategory == category ? Color.primaryNormal : Color(hex: "#EBEBEB"), lineWidth: 1)
                            )
                            .foregroundColor(selectedCategory == category ? Color.primaryNormal : Color(hex: "#363636"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private var sortInfo: some View {
        HStack {
            Text("총 32개")
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color.primaryNormal)
            Spacer()
            Button(action: {
                // 정렬 변경 동작
            }) {
                HStack(spacing: 4) {
                    Text(sortOrder)
                        .font(.hanSansNeo(13, .medium))
                        .foregroundColor(Color(hex: "#363636"))
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#363636"))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom,12)
    }
    
    private func section(month: String, articles: [Article]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(month)
                .font(.hanSansNeo(18, .bold))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            ForEach(articles) { article in
                BookmarkCard(article: article)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
        }
        .padding(.top, 20)
        .padding(.bottom,12)
        
    }
}

// MARK: - 카드 컴포넌트



// MARK: - Dummy Model & Sample

struct Article: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var brandName: String
    var brandImageName: String
    var date: String
}

let sampleArticles: [Article] = [
    .init(title: "🧠 신입사원 시절 '최악의 실수'는?", description: "출연하는 두뇌 서바이벌로 개인적 아쉬움이 남았던 das;lfdsa;lfal;skdfl;kasdjfl;kasdjflk;ajsdlk;fjasldk;jlask;dflak;sdflask;d", brandName: "주간 컴퍼니타임스", brandImageName: "logo1", date: "2023-11-26"),
    .init(title: "🥓 SNS에서 주목받는 브랜드의 비법 노트", description: "GS25는 한정 판매로 중량 4kg에 달하는 넷플릭스...das;lfdsa;lfal;skdfl;kasdjfl;kasdjflk;ajsdlk;fjasldk;jlask;dflak;sdflask;d", brandName: "고구마팜", brandImageName: "logo2", date: "2023-11-26"),
    .init(title: "💰 어피티 퇴사, 그 이후..", description: "국내 OTT인 티빙도 멤버십 구독료를 인상해요...das;lfdsa;lfal;skdfl;kasdjfl;kasdjflk;ajsdlk;fjasldk;jlask;dflak;sdflask;d", brandName: "머니레터", brandImageName: "logo3", date: "2023-11-25")
]
