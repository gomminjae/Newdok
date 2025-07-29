//
//  BookmarkViewResult.swift
//  Bookmark
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import DesignSystem
import Domain
import Shared

public struct BookmarkViewResult: View {
    @StateObject private var viewModel: BookmarkViewModelResult
    @State private var showSortSheet = false
    @EnvironmentObject private var router: AppRouter
    
    public init(viewModel: BookmarkViewModelResult) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading {
                    loadingView
                } else if let bookmarks = viewModel.sortedBookmarks {
                    if bookmarks.totalAmount > 0 {
                        contentView(bookmarks: bookmarks)
                    } else {
                        emptyView
                    }
                } else {
                    emptyView
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchUserInterests()
                    await viewModel.fetchUserBookmarks()
                }
            }
            .sheet(isPresented: $showSortSheet) {
                BookmarkSortBottomSheet(
                    sortOrder: $viewModel.sortOrder,
                    onSelect: {
                        // 정렬은 이미 ViewModel에서 자동으로 처리됨
                    }
                )
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            }
            .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("확인") {
                    // 에러 메시지는 자동으로 초기화됨
                }
                Button("다시 시도") {
                    Task { await viewModel.refreshData() }
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("북마크")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color(hex: "161616"))
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                .scaleEffect(1.2)
            
            Text("북마크를 불러오고 있습니다...")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "CCCCCC"))
            
            Text("저장된 북마크가 없습니다")
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "161616"))
            
            Text("관심있는 아티클을 북마크하고\n나중에 다시 읽어보세요")
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .multilineTextAlignment(.center)
            
            Button("뉴스레터 둘러보기") {
                router.resetTo(.tabbar(selectedTab: .explore))
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryNormal)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func contentView(bookmarks: BookmarkedArticles) -> some View {
        VStack(spacing: 0) {
            filterAndSortSection(totalCount: bookmarks.totalAmount)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(bookmarks.bookmarkForMonth, id: \.month) { monthData in
                        monthSection(monthData: monthData)
                    }
                }
            }
        }
    }
    
    private func filterAndSortSection(totalCount: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("총 \(totalCount)개")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "565656"))
                
                Spacer()
                
                Button {
                    showSortSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.sortOrder)
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color(hex: "161616"))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "565656"))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // 관심사 필터
            if !viewModel.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        interestFilterChip(title: "전체", isSelected: viewModel.interest.isEmpty)
                        
                        ForEach(viewModel.interests, id: \.id) { interest in
                            interestFilterChip(title: interest.name, isSelected: viewModel.interest == interest.name)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private func interestFilterChip(title: String, isSelected: Bool) -> some View {
        Button {
            let newInterest = isSelected ? "" : title
            Task {
                await viewModel.changeInterestFilter(newInterest == "전체" ? "" : newInterest)
            }
        } label: {
            Text(title)
                .font(.hanSansNeo(12, .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "565656"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.primaryNormal : Color(hex: "F5F5F5"))
                .cornerRadius(16)
        }
    }
    
    private func monthSection(monthData: MonthlyBookmark) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(monthData.month)
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color(hex: "161616"))
                
                Spacer()
                
                Text("\(monthData.bookmark.count)개")
                    .font(.hanSansNeo(12, .medium))
                    .foregroundStyle(Color(hex: "999999"))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            LazyVStack(spacing: 12) {
                ForEach(monthData.bookmark, id: \.articleId) { bookmark in
                    BookmarkRow(
                        bookmark: bookmark,
                        onTap: {
                            router.push(.articleDetail(id: bookmark.articleId))
                        },
                        onBookmarkTap: {
                            Task {
                                let result = await viewModel.toggleBookmark(articleId: bookmark.articleId)
                                // 토글 결과에 따른 추가 처리가 필요하면 여기서
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Supporting Views
private struct BookmarkSortBottomSheet: View {
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
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: "565656"))
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
                                .foregroundColor(Color(hex: "363636"))
                            Spacer()
                            if sortOrder == option.value {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "#2866D3"))
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 56)
                    }
                    
                    if option.value != sortOptions.last?.value {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
            .padding(.top, 28)
            
            Spacer()
        }
        .clipShape(.rect(topLeadingRadius: 24, topTrailingRadius: 24))
    }
}

private struct BookmarkRow: View {
    let bookmark: Bookmark
    let onTap: () -> Void
    let onBookmarkTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(bookmark.title)
                        .font(.hanSansNeo(16, .medium))
                        .foregroundStyle(Color(hex: "161616"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button(action: onBookmarkTap) {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.primaryNormal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(bookmark.content)
                    .font(.hanSansNeo(14, .regular))
                    .foregroundStyle(Color(hex: "565656"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text(bookmark.brandName)
                        .font(.hanSansNeo(12, .medium))
                        .foregroundStyle(Color(hex: "999999"))
                    
                    Spacer()
                    
                    Text(bookmark.date)
                        .font(.hanSansNeo(12, .regular))
                        .foregroundStyle(Color(hex: "999999"))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 