//
//  SearchResultView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import Kingfisher
import DesignSystem
import Shared

public struct SearchResultView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = "뉴닉"
    
    @EnvironmentObject private var router: AppRouter
    
    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            

            HStack(spacing: 0) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                }

                HStack(spacing: 8) {
                    TextField("검색어를 입력하세요", text: $searchText)
                        .font(.system(size: 16))
                        .disableAutocorrection(true)
                       
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)

            // MARK: - 스크롤 콘텐츠
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - 뉴스레터 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("뉴스레터")
                            .font(.hanSansNeo(16,.medium))
                        
                        HStack(spacing: 12) {
                            Image("banner")
                                .resizable()
                                .frame(width: 58, height: 58)
                                .cornerRadius(10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("NEWNEEK")
                                    .font(.hanSansNeo(16,.medium))
                                Text("세상 돌아가는 소식, 뉴닉으로!")
                                    .font(.hanSansNeo(14,.regular))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)

                    // MARK: - 아티클 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("아티클 (52)")
                            .font(.hanSansNeo(16,.medium))

                        ForEach(0..<3) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🦔 정부24 먹통 사건의 전말.txt")
                                    .font(.hanSansNeo(16,.medium))
                                    .lineLimit(1)

                                Text("오늘의 뉴닉 지난 주말 일어난 행정복지센터·정부24 서비스 먹통 사태...")
                                    .font(.hanSansNeo(14,.regular))
                                    .foregroundColor(.gray)
                                    .lineLimit(2)

                                HStack {
                                    Image("signup")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .background(.red)
                                        .clipShape(Circle())

                                    Text("주간 컴퍼니타임스")
                                        .font(.hanSansNeo(14,.medium))
                                        .bold()

                                    Spacer()

                                    Text("2023-11-26")
                                        .font(.hanSansNeo(12,.regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 2)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 50)
                }
                .padding(.top, 10)
            }
            .background(Color.gray.opacity(0.05))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SearchResultView()
    }
}
