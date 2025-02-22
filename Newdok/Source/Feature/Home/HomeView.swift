//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//

import SwiftUI

struct HomeView: View {
    
    let sampleArticles: [Article] = [
        Article(title: "💰 도커스님의 희망 은퇴 연령은?", source: "머니레터", imageName: "moneyletter", isRead: false),
        Article(title: "애플, 9년 만에 내놓은 신제품은?", source: "Daily Byte", imageName: "dailybyte", isRead: false),
        Article(title: "A-Z, 시민단체 보조금 논란", source: "NEWNEEK", imageName: "newneek", isRead: true),
        Article(title: "Apple WWDC24 특집, 지금 바로 확인해보세요!", source: "깨달로그", imageName: "kkaedalogue", isRead: true),
        Article(title: "📈 원운원 그거.. 어떻게 잘하는 건데?", source: "팁스터", imageName: "tipster", isRead: false),
        Article(title: "🧠 ChatGPT는 진짜 사람처럼 생각할까?", source: "AI Insight", imageName: "aiinsight", isRead: false)
    ]
   
    var body: some View {
        VStack {
            HStack {
                Image("logo")
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    print("검색")
                }) {
                    Image("search")
                        .padding(.trailing,2.4)
                }
                Button(action: {
                    print("알람")
                }) {
                    Image("bell")
                        .padding(.leading, 2.4)
                        .padding(.trailing,17.8)
                }
            }
            HStack {
                Text("2024년 5월 23일 수요일")
                    .font(.hanSansNeo(16,.medium))
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    print("calendar")
                }) {
                    Image("calendar_logo")
                        .padding(.trailing, 17.8)
                }
            }
            .padding(.top, 16)
            
            VStack {
                HStack {
                    Text("6개의 아티클이 도착했어요.")
                        .font(.hanSansNeo(18,.bold))
                        .padding(.top, 20)
                        .padding(.leading, 28)
                    Spacer()
                    Button(action: {
                        print("calendara")
                    }) {
                        Image("refresh")
                        Text("새로고침")
                            .font(.hanSansNeo(12,.regular))
                            .foregroundStyle(Color.primaryNormal)
                    }
                    .padding(.trailing, 28)
                    .padding(.top, 20)
                }
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sampleArticles) { article in
                            ArticleRow(article: article)
                                .frame(height: 88)
                                .padding(.horizontal, 24)
                            
                        }
                    }
                    .padding()
                }
                
            }
            .background(Color(hex: "F5F5F7"))
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
            Image("signup")
                .resizable()
                .frame(width: 56, height: 56)
                .background(Color.orange)
                .cornerRadius(12)
            
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
        .background(Color.white)
        .cornerRadius(12)
    }
}


#Preview {
    HomeView()
}
