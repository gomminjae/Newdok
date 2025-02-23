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
    
    
    @State private var isRefreshing = false
    @State private var spinnerScale: CGFloat = 0.5 // 스피너 크기 조절
    @State private var rotationAngle: Double = 0 // 스피너 회전 효과
    
    var body: some View {
        VStack {
            HStack {
                Image("darklogo")
                    .padding(.top, 18)
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    print("검색")
                }) {
                    Image("search")
                        .padding(.top, 18)
                        .padding(.trailing,2.4)
                }
                Button(action: {
                    print("알람")
                }) {
                    Image("bell")
                        .padding(.top, 18)
                        .padding(.leading, 8)
                        .padding(.trailing,17.8)
                }
            }
            HStack {
                Text("2024년 5월 23일 수요일")
                    .font(.hanSansNeo(16,.medium))
                    .padding(.top, 16)
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    print("calendar")
                }) {
                    Image("calendar_logo")
                        .padding(.top, 16)
                        .padding(.trailing, 17.8)
                }
            }
            .padding(.top, 16)
            
            
            
            VStack {
                if sampleArticles.isEmpty {
                    NoDataView(type: .noArticles, buttonAction: {}, loginAction: {})
                } else {
                    ScrollView {
                        HStack {
                            Text("\(sampleArticles.count)개의 아티클이 도착했어요.")
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
                        }
                        VStack(spacing: 12) {
                            ForEach(sampleArticles) { article in
                                ArticleRow(article: article)
                                    .frame(height: 88)
                                    
                                
                            }
                        }
                        .padding()
                    }
                    .scrollIndicators(.hidden)
                   
                }
                Spacer()
                
            }
            .background(Color(hex: "F5F5F7"))
            
        }
    }
    private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isRefreshing = false // 로딩 종료
            }
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




#Preview {
    HomeView()
}
