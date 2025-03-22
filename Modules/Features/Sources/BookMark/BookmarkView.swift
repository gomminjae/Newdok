//
//  BookMark.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//
import SwiftUI

struct BookmarkView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // 상단 네비게이션 바
            HStack {
                Text("북마크함")
                    .font(.hanSansNeo(16, .bold))
                    .padding(.vertical, 17)
                    .padding(.leading, 20)
                Spacer()
                HStack(spacing: 16) {
                    Button(action: {
                        // 검색 버튼 액션
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        // 알림 버튼 액션
                    }) {
                        Image(systemName: "bell")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .padding(.trailing, 20)
            }
            
            // 태그 필터 (가로 스크롤)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["전체", "경제·상식", "과학·기술", "비즈니스", "트렌드", "여행", "시사"], id: \.self) { tag in
                        TagView(text: tag)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 17)
            }
            HStack {
                Text("총 4개")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundColor(Color(hex: "#2866D3"))
                    .padding(.leading, 24)
                Spacer()
                Button(action: {
                    // 정렬 버튼 액션
                }) {
                    HStack {
                        Text("추가순")
                            .foregroundColor(Color(hex: "#363636"))
                            .font(.hanSansNeo(14, .medium))
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.trailing, 20)
            }
            .padding(.bottom, 10)

            // 북마크 리스트
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    BookmarkSectionView(year: "2023년 11월", items: [
                        BookmarkItem(title: "🤯 신입사원 시절 '최악의 실수'는?",
                                     description: "출연하는 두뇌 서바이벌로, 개인적으로는 아쉬움이 남았던...",
                                     source: "주간 컴퍼니타임스",
                                     date: "2023-11-26")
                    ])
                    
                    BookmarkSectionView(year: "2023년 10월", items: [
                        BookmarkItem(title: "SPREAD by B | DISCOVER 서울의 새로운 이웃, 르메르",
                                     description: "서울 한남동에 자리한 매거진 <B> 오피스 맞은편에는...",
                                     source: "주간 컴퍼니타임스",
                                     date: "2023-10-26"),
                        BookmarkItem(title: "🌊 살면서 의도치 않게 뒤통수를 맞아도, 마음이 꼬여서는 안된다",
                                     description: "GS25는 한정 판매로 중량 4kg에 달하는 ‘넷플릭스 인간팜...",
                                     source: "주간 컴퍼니타임스",
                                     date: "2023-10-15")
                    ])
                }
            }
            .background(Color(hex: "#F5F5F7"))
        }
    }
}

// 태그 뷰
struct BookmarkTagView: View {
    var text: String
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.white)
            .foregroundColor(isSelected ? Color.blue : Color.black)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// 북마크 섹션 뷰
struct BookmarkSectionView: View {
    var year: String
    var items: [BookmarkItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(year)
                .font(.hanSansNeo(18, .bold))
                .padding(.horizontal, 24)
                .padding(.top, 10)

            ForEach(items, id: \.title) { item in
                BookmarkCardView(item: item)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// 북마크 카드 뷰
struct BookmarkCardView: View {
    var item: BookmarkItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.hanSansNeo(16, .bold))
            
            Text(item.description)
                .font(.hanSansNeo(14, .regular))
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                Text(item.source)
                    .font(.hanSansNeo(12, .regular))
                    .foregroundColor(.gray)
                Spacer()
                Text(item.date)
                    .font(.hanSansNeo(12, .regular))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

// 북마크 아이템 모델
struct BookmarkItem {
    let title: String
    let description: String
    let source: String
    let date: String
}

#Preview {
    BookmarkView()
}
