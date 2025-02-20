//
//  CompleteView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI

struct CompleteView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("뉴스레터 구독을 위한\n이메일이 생성되었어요.")
                .padding(.top,32)
            Image("signup")
            
            VStack {
                Text("구독 이메일")
                Text("test@newdok.site")
            }
            .padding(.horizontal, 20)
            
            Text("이제 뉴독으로 구독을 신청할 수 있어요.\n지금 바로 내게 도움이 될 뉴스레터를 만나보세요.")
            Spacer()
            Button(action: {
                print("다음 버튼 클릭됨")
            }) {
                Text("다음")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // 가로로 최대 확장
                    .frame(height: 56) // 높이 지정
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.bottom, 16)
          
           
        }
        .navigationTitle("회원가입 완료")
        .padding(.horizontal, 24)
    }
        
    
}

#Preview {
    CompleteView()
}
