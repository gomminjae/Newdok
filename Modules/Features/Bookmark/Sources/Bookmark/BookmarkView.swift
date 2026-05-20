//
//  BookmarkView.swift
//  Bookmark
//
//  Created by 권민재 on 5/1/25.
//  Copyright © 2025 Newdok. All rights reserved.
//

import SwiftUI
import DesignSystem
import BookmarkDomain
import Shared

// MARK: - 북마크 정렬 모달
struct BookmarkSortBottomSheet: View {
    @Environment(\.dismiss) private var dismiss

    let sortOptions: [(text: String, value: String)] = [
        ("추가순", "추가순"),
        ("최근 아티클 순", "최근 아티클 순"),
        ("오래된 아티클 순", "오래된 아티클 순")
    ]
    @Binding var sortOrder: String
    var onSelect: () async -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 그랩바
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)

            HStack {
                Text("정렬")
                    .font(.hanSansNeo(20, .bold))
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(asset: DesignSystemAsset.lineClose)
                }
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(sortOptions, id: \.value) { option in
                    Button(action: {
                        sortOrder = option.value
                        Task {
                            await onSelect()
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 0) {
                            Text(option.text)
                                .font(.hanSansNeo(14, .medium))
                                .foregroundColor(Color.captionStrong)
                            Spacer()
                            if sortOrder == option.value {
                                Image(asset: DesignSystemAsset.lineCheckmark)
                                    .renderingMode(.template)
                                    .foregroundColor(Color.primaryNormal)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    if option.value != sortOptions.last?.value {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
            .padding(.top, 28)

            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .presentationCornerRadius(24)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
    }
}

public struct BookmarkView: View {
    @State private var selectedCategory: String = "전체"
    @State private var showSortSheet = false
    
    @State private var viewModel: BookmarkViewModel

    @Environment(AppRouter.self) private var router
    @Environment(AppState.self) private var appState

    private var isGuest: Bool { appState.authState == .guest }

    public init(viewModel: BookmarkViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            categoryFilter
            sortInfo
            
            PullToRefreshView(
                    content: {
                        VStack(spacing: 0) {
                            if isGuest {
                                BookmarkGuestView(onLogin: {
                                    router.push(.login)
                                })
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else if viewModel.bookmarks?.totalAmount == 0 {
                                BookmarkEmptyView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(Array((viewModel.sortedBookmarks?.bookmarkForMonth ?? []).enumerated()), id: \.1.id) { index, monthly in
                                        section(month: monthly.month, articles: monthly.bookmark)
                                            .padding(.top, index == 0 ? 0 : 32)
                                    }
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                            }
                        }
                    },
                animationView: {
                    LoadingView()
                },
                onRefresh: {
                    if !isGuest {
                        await viewModel.fetchUserInterests()
                        await viewModel.fetchUserBookmarks()
                    }
                }
            )
            .background(Color.bgSystem)
        }
        .background(.white)
        .sheet(isPresented: $showSortSheet) {
            BookmarkSortBottomSheet(sortOrder: $viewModel.sortOrder) {
                // 정렬 변경 시 API를 다시 호출
                Task {
                    await viewModel.fetchUserBookmarks()
                }
            }
            .presentationDragIndicator(.hidden)
        }
        .onAppear {
            if !isGuest {
                viewModel.loadInitial()
            }
        }
        .onChange(of: appState.authState) { _, newValue in
            if newValue == .guest {
                viewModel.clearData()
            } else {
                viewModel.loadInitial()
            }
        }
        .onDisappear { viewModel.cancelLoads() }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onRetry: { viewModel.loadInitial() }
        )
    }
    
    private var headerView: some View {
        HStack {
            Text("북마크함")
                .font(.hanSansNeo(18, .bold))
                .foregroundStyle(Color.captionHeavy)
            Spacer()
            Button {
                router.push(.search)
            } label: {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 17)
        .background(Color.white)
    }
    
    private var categoryFilter: some View {
        let sortedCategories: [(Int?, String)] = [(nil, "전체")] + viewModel.interests.map { ($0.id, $0.name) }

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(sortedCategories, id: \.0) { id, name in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = name
                        }
                        Task {
                            viewModel.interest = id != nil ? "\(id!)" : ""
                            await viewModel.fetchUserBookmarks()
                        }
                    }) {
                        Text(name)
                            .font(.hanSansNeo(13, .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedCategory == name ? Color.primaryNormal : Color.lineNeutral, lineWidth: 1)
                            )
                            .foregroundColor(selectedCategory == name ? Color.primaryNormal : Color.captionStrong)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private var sortInfo: some View {
        HStack {
            Text("총 \(viewModel.bookmarks?.totalAmount ?? 0)개")
                .font(.hanSansNeo(20, .bold))
                .foregroundColor(Color.primaryNormal)
            Spacer()
            Button(action: {
                showSortSheet = true
            }) {
                HStack(spacing: 0) {
                    Text(viewModel.sortOrder)
                        .font(.hanSansNeo(13, .medium))
                        .foregroundColor(Color.captionStrong)
                    Image(asset: DesignSystemAsset.updown)
                        .renderingMode(.template)
                        .foregroundColor(Color.captionStrong)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
    
    private func section(month: String, articles: [BookmarkItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(month)
                .font(.hanSansNeo(18, .bold))
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            
            ForEach(articles) { article in
                BookmarkCard(article: article)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.push(.articleDetail(id: "\(article.id)"))
                    }
            }
        }
    }
}
