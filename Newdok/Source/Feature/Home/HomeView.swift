//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//

import SwiftUI

struct HomeView: View {
    let articles: [Article] = [
        Article(title: "💰 도커스님의 희망 은퇴 연령은?", source: "머니레터", imageName: "moneyletter", isRead: false),
        Article(title: "애플, 9년만에 내놓은 신제품은?", source: "Daily Byte", imageName: "dailybyte", isRead: false),
        Article(title: "A-Z, 시민단체 보조금 논란", source: "NEWNEEK", imageName: "newneek", isRead: true),
        Article(title: "Apple WWDC23 특집, 지금 바로 확인해...", source: "깨달로그", imageName: "kkaedalogue", isRead: true),
        Article(title: "원운원 그거.. 어떻게 잘하는 건데?", source: "팁스터", imageName: "tipster", isRead: false)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 24)
                
                Spacer()
                
                Image(systemName: "bell")
                    .font(.system(size: 20))
                
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .padding(.leading, 16)
            }
            .padding(.horizontal)
            .padding(.top, 8)

         
            Text("2024년 5월 23일 수요일")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .padding(.top, 4)

           
            HStack {
                Text("6개의 아티클이 도착했어요.")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    print("새로고침 클릭")
                }) {
                    Text("새로고침")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // 🔹 4. 아티클 리스트
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(articles) { article in
                        ArticleRow(article: article)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)

            // 🔹 5. 하단 탭 바
            Spacer()
            CustomTabBar()
        }
    }
}

struct Article: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let imageName: String
    let isRead: Bool
}

struct ArticleRow: View {
    let article: Article

    var body: some View {
        HStack {
            Image("signup") // 썸네일 이미지
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .background(Color.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.source)
                    .font(.system(size: 14, weight: .bold))
                
                Text(article.title)
                    .font(.system(size: 16))
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(article.isRead ? "읽음" : "안읽음")
                .font(.system(size: 14))
                .foregroundColor(article.isRead ? .gray : .blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// ✅ 하단 탭 바 (TabView)
struct CustomTabBar: View {
    var body: some View {
        HStack {
            TabItem(icon: "square.grid.2x2", label: "둘러보기")
            TabItem(icon: "tray.fill", label: "구독관리")
            TabItem(icon: "house.fill", label: "홈", isSelected: true)
            TabItem(icon: "book.fill", label: "북마크함")
            TabItem(icon: "person.fill", label: "마이페이지")
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color.white)
    }
}

// ✅ 개별 탭 아이템
struct TabItem: View {
    let icon: String
    let label: String
    var isSelected: Bool = false

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .blue : .gray)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
}
