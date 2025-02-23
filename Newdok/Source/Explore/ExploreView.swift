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
    
    let personalizedNewsletters: [Newsletter] = [
        Newsletter(title: "노폴레터", description: "크리에이티브한 창작자들의 인사이트와 작업 이야기", imageName: "nofolletter", tags: ["시사·상식", "비즈니스", "트렌드"]),
        Newsletter(title: "더슬랭", description: "현대인들을 위한 깊이 있는 시사 뉴스레터", imageName: "theslang", tags: ["시사·상식", "비즈니스", "트렌드"])
        ]
    var body: some View {
        VStack {
            HStack {
                Text("둘러보기")
                    .font(.hanSansNeo(18,.bold))
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
        }
    }
}



#Preview {
    ExploreView()
}
