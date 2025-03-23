//
//  SearchView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

public struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: - 커스텀 네비게이션 바
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }

                TextField("검색어 입력", text: $searchText)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .opacity(searchText.isEmpty ? 0 : 1)
                }

                Button(action: {
                    // 검색 액션
                }) {
                    Image("search")
                        .foregroundStyle(.black)
                }
            }
            .padding()
            .background(Color.white.shadow(radius: 1))
            
            Divider()

         
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("인기검색어")
                        .font(.hanSansNeo(16, .medium))
                    Spacer()
                    Text("11/21 업데이트")
                        .font(.hanSansNeo(11,.regular))
                        .foregroundColor(.primaryNormal)
                }
                .padding(.bottom, 10)

                ForEach(1..<7) { num in
                    HStack(spacing: 16) {
                        Text("\(num)")
                            .font(.hanSansNeo(14,.medium))
                            .foregroundColor(.primaryNormal)
                            
                        
                        Text(sampleWord(num))
                            .font(.hanSansNeo(14,.regular))
                            .foregroundColor(Color(hex: "333333"))
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // 임시 데이터
    private func sampleWord(_ num: Int) -> String {
        switch num {
        case 1: return "뉴닉"
        case 2: return "데일리바이트"
        case 3: return "트렌드"
        case 4: return "콘텐츠"
        case 5: return "재테크"
        case 6: return "IT"
        default: return ""
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
}
