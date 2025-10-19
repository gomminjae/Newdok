//
//  SearchView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import Domain
import Shared
import DesignSystem

public struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SearchViewModel
    @EnvironmentObject private var router: AppRouter
    
    public init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button(action: { router.pop() }) {
                    Image(asset: DesignSystemAsset.back)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(hex: "#969696"))
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
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(hex: "#DADADA"))
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

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            } else if !viewModel.searchResults.isEmpty {
                // 검색 결과가 있을 때 - SearchResultView와 동일한 UI
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        newsletterSection()
                        // 비회원일 때는 아티클 섹션 숨김
                        if TokenStorage.hasValidToken {
                            articleSection()
                        }
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
                        // 비회원일 때는 아티클 섹션 숨김
                        if TokenStorage.hasValidToken {
                            articleSection()
                        }
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 10)
                }
                .background(Color.gray.opacity(0.05))
            } else {
                // 검색어가 없을 때 - 인기검색어 표시
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("인기검색어")
                            .font(.hanSansNeo(16, .medium))
                        Spacer()
                        Text("10/11 업데이트")
                            .font(.hanSansNeo(12,.medium))
                            .foregroundColor(.primaryNormal)
                    }
                    .padding(.bottom, 8)

                    ForEach(1..<6) { num in
                        HStack(spacing: 16) {
                            Text("\(num)")
                                .font(.hanSansNeo(14,.medium))
                                .foregroundColor(.primaryNormal)
                            
                            Text(sampleWord(num))
                                .font(.hanSansNeo(14,.medium))
                                .foregroundColor(Color(hex: "#565656"))
                            Spacer()
                        }

                        .onTapGesture {
                            let brandId = getBrandId(for: num)
                            router.push(.brandDetail(id: "\(brandId)"))
                        }
                    }
                    Spacer()
                }
                .padding(24)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    // 임시 데이터
    private func sampleWord(_ num: Int) -> String {
        switch num {
        case 1: return "NEWNEEK"
        case 2: return "Daily Byte"
        case 3: return "머니레터"
        case 4: return "마케팅킹"
        case 5: return "오렌지레터"
        case 6: return "IT"
        default: return ""
        }
    }
    
    // 인기검색어에 대응하는 브랜드 ID 반환 (하드코딩)
    private func getBrandId(for rank: Int) -> Int {
        switch rank {
        case 1: return 1  // 뉴닉
        case 2: return 2   // 데일리바이트
        case 3: return 8   // 머니레터
        case 4: return 73   // 마케팅킹
        case 5: return 46   // 오렌지레터
        default: return 1
        }
    }
    
    // MARK: - 검색 결과 섹션들
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
    
    // 더미 아티클 데이터
    private var dummyArticles: [SearchDummyArticle] {
        [
            SearchDummyArticle(id: 1, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
            SearchDummyArticle(id: 2, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
            SearchDummyArticle(id: 3, title: "신입사원 시절 '최악의 실수'는?", summary: "출연하는 두뇌 서버바이블로, 개인적으로는 아쉬움이 남았던 넷플릭스 두뇌 서버바이블 <데블스플랜>에 대한 감정...", brandName: "주간 컴퍼니타임스", date: "2023-11-26"),
        ]
    }
}

// MARK: - 검색 결과 컴포넌트들
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
                        .stroke(Color(hex: "#EBEBEB"), lineWidth: 1)
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
