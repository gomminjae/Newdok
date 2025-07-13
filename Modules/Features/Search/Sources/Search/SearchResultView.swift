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
            HStack(spacing: 0) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(8)
                }
                HStack(spacing: 8) {
                    TextField("검색어를 입력하세요", text: $viewModel.searchText)
                        .font(.system(size: 16))
                        .disableAutocorrection(true)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.6))
                }
                Button(action: {
                    Task { await viewModel.searchNewsletters() }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(.red)
                    } else {
                        newsletterSection()
                        articleSection()
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
                .frame(width: 58, height: 58)
                .cornerRadius(10)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(result.brandName)
                    .font(.hanSansNeo(16,.medium))
                Text(result.firstDescription)
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
    private func articleSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("아티클 (\(dummyArticles.count))")
                .font(.hanSansNeo(16,.medium))
            ForEach(dummyArticles) { article in
                SearchArticleRow(article: article)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func newsletterSection() -> some View {
        if !viewModel.searchResults.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("뉴스레터")
                    .font(.hanSansNeo(16,.medium))
                ForEach(viewModel.searchResults, id: \.id) { result in
                    SearchNewsletterRow(result: result)
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
