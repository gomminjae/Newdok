//
//  SearchResultView 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//




import SwiftUI
import Kingfisher
import DesignSystem
import Shared
import Domain

public struct SearchResultView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel: SearchViewModel

    public init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                }

                HStack(spacing: 8) {
                    TextField("검색어를 입력하세요", text: $viewModel.searchText)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.searchNewsletters() }
                        }
                        .font(.hanSansNeo(14, .regular))
                        .disableAutocorrection(true)
                        .frame(height: 40)

                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 14, height: 14)
                                .foregroundColor(.gray.opacity(0.6))
                        }
                        .padding(.trailing, 4)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                .cornerRadius(10)
                Button(action: {
                    Task { await viewModel.searchNewsletters() }
                }) {
                    Image(asset: DesignSystemAsset.lineSearch)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.primary)
                }
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)
            
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)
                    } else {
                        newsletterSection()
                        // 비회원일 때는 아티클 섹션 숨김
                        if TokenStorage.hasValidToken {
                            articleSection()
                        }
                    }
                    Spacer(minLength: 50)
                }
                .padding(.top, 10)
            }
            .background(Color.gray.opacity(0.05))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveUnauthorized)) { _ in
            // 로그아웃 시 검색 결과 초기화
            viewModel.clearSearchResults()
        }
        .onReceive(NotificationCenter.default.publisher(for: .didLoginSuccess)) { _ in
            // 로그인 성공 시 검색 결과 초기화
            viewModel.clearSearchResults()
        }
    }
}

struct SearchNewsletterRow: View {
    let result: SearchedNewsletter
    var body: some View {
        HStack(spacing: 12) {
            if let url = URL(string: result.imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#EBEBEB"))
                }
                .frame(width: 56, height: 56)
                .cornerRadius(10)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(result.brandName)
                    .font(.hanSansNeo(14,.bold))
                    .foregroundStyle(Color(hex: "#333333"))
                Text(result.firstDescription)
                    .font(.hanSansNeo(14,.medium))
                    .foregroundColor(Color(hex:"#363636"))
            }
            Spacer()
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 2)
    }
}

struct DummyArticle: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let brandName: String
    let date: String
}

struct SearchArticleRow: View {
    let article: DummyArticle
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.hanSansNeo(16,.medium))
                .lineLimit(1)
            Text(article.summary)
                .font(.hanSansNeo(14,.regular))
                .foregroundColor(.gray)
                .lineLimit(2)
            HStack {
                Text(article.brandName)
                    .font(.hanSansNeo(14,.medium))
                    .bold()
                Spacer()
                Text(article.date)
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

extension SearchResultView {
    private var dummyArticles: [DummyArticle] {
        [
            DummyArticle(id: 1, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
            DummyArticle(id: 2, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
            DummyArticle(id: 3, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
        ]
    }

    @ViewBuilder
    private func newsletterEmptySection() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text("검색 결과가 없어요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 8)
            Text("찾는 뉴스레터가 없다면 등록을 요청해보세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color(hex: "#565656"))
            Button(action: {
               
                router.push(.feedback)
            }) {
                Text("뉴스레터 등록 요청하기")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.primaryNormal)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.primaryNormal, lineWidth: 1)
                    )
            }
            .frame(height: 48)
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func articleSection() -> some View {
        // 더미 데이터이므로 결과 없음 UI는 제외
        if !dummyArticles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("아티클 (\(dummyArticles.count))")
                    .font(.hanSansNeo(16,.medium))
                ForEach(dummyArticles) { article in
                    Button(action: {
                        router.push(.articleDetail(id: String(article.id)))
                    }) {
                        SearchArticleRow(article: article)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func newsletterSection() -> some View {
        if viewModel.searchResults.isEmpty {
            newsletterEmptySection()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("뉴스레터")
                    .font(.hanSansNeo(16,.medium))
                ForEach(viewModel.searchResults, id: \.id) { result in
                    Button(action: {
                        router.push(.brandDetail(id: result.id))
                    }) {
                        SearchNewsletterRow(result: result)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
    }
}


//#Preview {
//    NavigationStack {
//        SearchResultView()
//    }
//}
