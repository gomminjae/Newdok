//
//  NewsLetterView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import DesignSystem

public struct NewsLetterView: View {
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 이미지와 태그
                ZStack(alignment: .topLeading) {
                    Image("banner")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
                        .clipped()
                    
                    HStack(spacing: 8) {
                        LetterTagView(text: "시사·상식")
                        LetterTagView(text: "비즈니스")
                        LetterTagView(text: "트렌드")
                        Spacer()
                        Text("구독중")
                            .frame(width: 50, height: 26)
                            .background(Color(hex: "#5184DB"))
                            .foregroundStyle(Color.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 12)
                    .padding(.leading, 16)
                }
                .frame(maxWidth: .infinity)

                // 프로필 카드
                profileCardView
                    .offset(y: -20)
                    .zIndex(1)

                // 메인 컨텐츠
                VStack(alignment: .leading, spacing: 20) {
                    // 구분선과 설명
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                            .padding(.top, 30)
                        
                        Text("세상 돌아가는 소식은 궁금한데, 시간이 없다고요? <뉴닉>은 신문 볼 새 없이 바쁘지만, 세상과의 연결고리는 튼튼하게 유지하고 싶은 여러분들을 위해 세상 돌아가는 소식을 모두 담아 간단하게 정리해드려요.")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 20)
                    
                    // 지난 아티클 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("지난 아티클 보기")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundColor(Color(hex: "#161616"))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ArticleCard(title: "🦔정원 늘어난다 쭉쭉쭉쭉~?", date: "6월 12일 (월) 오전 7:06")
                            ArticleCard(title: "(광고)🦔우리 사이 멀어질까 두려워", date: "6월 9일 (금) 오전 5:57")
                            ArticleCard(title: "🦔또 내 지갑만 진심(으론 텅텅)이지만", date: "6월 8일 (목) 오전 6:34")
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .background(Color.white)
                .cornerRadius(20)
                .offset(y: -50)
                .padding(.horizontal, 16)
            }
            .background(Color(hex: "#F5F5F7"))
        }
    }
    
    public var profileCardView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEWNEEK")
                    .font(.hanSansNeo(16, .bold))
                Label("매주 평일 아침", systemImage: "clock")
                    .font(.hanSansNeo(12, .regular))
                    .foregroundColor(Color(hex: "#565656"))
            }
            Spacer()
            Button(action: {}) {
                Text("구독하기")
                    .font(.hanSansNeo(14, .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "ffffff").opacity(0.6))
                .shadow(radius: 3)
        )
        .padding(.horizontal, 16)
    }
}

// 개별 태그 뷰
public struct LetterTagView: View {
    var text: String
    public var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.white.opacity(0.61))
            .foregroundColor(Color.black.opacity(0.8))
            .clipShape(Capsule())
    }
}

// 개별 아티클 카드 뷰
public struct ArticleCard: View {
    var title: String
    var date: String
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#161616"))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(date)
                .font(.hanSansNeo(12, .regular))
                .foregroundColor(Color(hex: "#565656"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
