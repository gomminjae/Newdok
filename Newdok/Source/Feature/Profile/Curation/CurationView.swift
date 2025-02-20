//
//  CurationView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI

struct CurationView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("닉네임님을 위한\n맞춤형 뉴스레터가 도착했어요!")
            Text("구독한 뉴스레터는 발행일에 맞춰 홈으로 배달해드려요.\n구독하기를 누르면 구독 이메일이 자동으로 복사돼요.")
        }
        .navigationTitle("추천 뉴스레터")
    }
}



#Preview {
    CurationView()
}
