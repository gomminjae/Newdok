//
//  SearchView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import SearchDomain
import Shared
import DesignSystem
import Kingfisher

public struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SearchViewModel
    @Environment(AppRouter.self) private var router
    
    public init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.captionAssistive)
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
                        .accessibilityIdentifier("search_textfield")

                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.lineAlternative)
                        }
                        .accessibilityLabel("검색어 지우기")
                        .accessibilityIdentifier("search_clear_button")
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
                .accessibilityLabel("검색")
                .accessibilityIdentifier("search_submit_button")
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(Divider(), alignment: .bottom)
            
            Divider()

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .tint(Color.primaryNormal)
                Spacer()
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            } else if !viewModel.searchResults.isEmpty {
                // 검색 결과가 있을 때 - SearchResultView와 동일한 UI
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        newsletterSection()
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 10)
                }
                .background(Color.gray.opacity(0.05))
            } else if !viewModel.searchText.isEmpty {
                // 검색어가 있지만 결과가 없을 때 - 빈 결과 뷰
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        newsletterSection()
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 10)
                }
                .background(Color.gray.opacity(0.05))
            } else {
                popularKeywordsSection()
            }
            Spacer()
        }

        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadPopularKeywords()
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: { Task { await viewModel.loadPopularKeywords() } }
        )
    }

    @ViewBuilder
    private func popularKeywordsSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("인기검색어")
                    .font(.hanSansNeo(16, .medium))
                Spacer()
                if let updatedDate = viewModel.popularKeywords?.updatedDate {
                    Text("\(updatedDate) 업데이트")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(.primaryNormal)
                }
            }
            .padding(.bottom, 8)
            
            if viewModel.isPopularLoading {
                ProgressView()
                    .tint(Color.primaryNormal)
                    .frame(maxWidth: .infinity)
            } else if let keywords = viewModel.popularKeywords?.keywords, !keywords.isEmpty {
                ForEach(keywords) { keyword in
                    popularKeywordRow(keyword)
                }
            } else if let error = viewModel.popularErrorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    Text(error)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(.primaryNormal)
                    Button("다시 시도하기") {
                        Task { await viewModel.loadPopularKeywords(force: true) }
                    }
                    .font(.hanSansNeo(14, .medium))
                }
            } else {
                Text("표시할 인기 검색어가 없습니다.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }
    
    private func popularKeywordRow(_ keyword: PopularKeyword) -> some View {
        HStack(spacing: 16) {
            Text("\(keyword.rank)")
                .font(.hanSansNeo(14, .bold))
                .foregroundColor(.primaryNormal)
            
            Text(keyword.keyword)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionNeutral)
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            Task { await viewModel.selectPopularKeyword(keyword.keyword) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(keyword.rank)위, \(keyword.keyword)")
        .accessibilityIdentifier("search_keyword_\(keyword.rank)")
    }
    
    // MARK: - 검색 결과 섹션들
    @ViewBuilder
    private func newsletterSection() -> some View {
        if viewModel.searchResults.isEmpty {
            newsletterEmptySection()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("뉴스레터")
                    .font(.hanSansNeo(16, .medium))
                ForEach(viewModel.searchResults, id: \.id) { result in
                    Button(action: {
                        router.push(.brandDetail(id: result.id))
                    }) {
                        SearchNewsletterRow(result: result)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityIdentifier("search_result_\(result.id)")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
    }
    
    @ViewBuilder
    private func newsletterEmptySection() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text("검색 결과가 없어요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 8)
            Text("찾는 뉴스레터가 없다면 등록을 요청해보세요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionNeutral)
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
}

