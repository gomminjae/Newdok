//
//  SearchResultView 2.swift
//  Search
//
//  Created by 권민재 on 7/13/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
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
                    }
                    Spacer(minLength: 50)
                }
                .padding(.top, 10)
            }
            .background(Color.gray.opacity(0.05))
        }

        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .enableSwipeBack()
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

extension SearchResultView {
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
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
        }
    }
}

// #Preview {
//    NavigationStack {
//        SearchResultView()
//    }
// }
