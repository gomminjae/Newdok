//
//  SearchView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import Domain

public struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SearchViewModel
    
    public init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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

                TextField("검색어 입력", text: $viewModel.searchText)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                        .opacity(viewModel.searchText.isEmpty ? 0 : 1)
                }

                Button(action: {
                    Task { await viewModel.searchNewsletters() }
                }) {
                    Image("search")
                        .foregroundStyle(.black)
                }
            }
            .padding()
            .background(Color.white.shadow(radius: 1))
            
            Divider()

            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            } else if !viewModel.searchResults.isEmpty {
                List(viewModel.searchResults, id: \.id) { result in
                    Text(result.brandName) // 예시
                }
            } else {
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
            }
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

