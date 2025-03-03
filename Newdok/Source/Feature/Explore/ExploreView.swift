//
//  ExploreView.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI

struct ExploreView: View {
    @State private var selectedTab: Int = 0 // 0: 추천 뉴스레터, 1: 모든 뉴스레터
    @State private var currentPage: Int = 0 // 페이지 컨트롤 인덱스
    
    // 닉네임 예시
    let userName = "닉네임"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("둘러보기")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.vertical, 17)
                    .padding(.leading, 20)
                Spacer()
                Button(action: {
                    print("검색 버튼 탭")
                }) {
                    Image("search")
                        .padding(.top, 18)
                        .padding(.trailing, 2.4)
                }
                Button(action: {
                    print("알람 버튼 탭")
                }) {
                    Image("bell")
                        .padding(.top, 18)
                        .padding(.leading, 16)
                        .padding(.trailing, 17.8)
                }
            }
            
            HStack(spacing: 0) {
                tabButton(title: "추천 뉴스레터", index: 0)
                tabButton(title: "모든 뉴스레터", index: 1)
            }
            .padding(.top, 16)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text("닉네임님을 위한\n맞춤형 뉴스레터가 도착했어요.")
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 20)
                        .padding(.horizontal, 28)
                    
                    // 캐러셀 (RecommendedNewsLetterView를 여러 개 보여줌)
                    TabView {
                        ForEach(0..<5, id: \.self) { _ in
                            RecommendedNewsLetterView()
                                .frame(width: 320, height: 350)
                                .cornerRadius(12)
                        }
                    }
                    .frame(height: 350)
                    .tabViewStyle(.page)
                    //.padding(.horizontal, 20)
                    
                    HStack {
                        Text("이런 뉴스레터는 어때요?")
                            .font(.hanSansNeo(16, .bold))
                        Spacer()
                        Button("새로고침") {
                            print("hello world")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    
                    // 뉴스레터 목록 리스트
                    List {
                        ForEach(0..<10, id: \.self) { index in
                            ArticleRow(article: Article(title: "dfdf", source: "sdfsdf", imageName: "signup_icon", isRead: false))
                        }
                    }
                    .frame(height: 400) // 리스트 높이 조절
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(hex: "#F5F5F7"))
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - 탭 버튼 뷰
    @ViewBuilder
    private func tabButton(title: String, index: Int) -> some View {
        Button(action: {
            selectedTab = index
        }) {
            Text(title)
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(selectedTab == index ? Color(hex: "#363636") : Color(hex: "#767676"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                
        }
    }
    
    
   
}

#Preview {
    ExploreView()
}
