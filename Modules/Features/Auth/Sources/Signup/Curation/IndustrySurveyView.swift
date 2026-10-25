//
//  IndustrySurveyView.swift
//  Newdok
//
//  Created by 권민재 on 2/20/25.
//

import SwiftUI
import DesignSystem
import AuthDomain

public struct InterestSelectionView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    @Bindable private var viewModel: SignupViewModel

    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("정확한 추천을 위해\n관심사를 3개 이상 선택해주세요.")
                .font(.hanSansNeo(20, .bold))
                .padding(.top, 24)

            Text("취향에 맞는 뉴스레터를 추천해드려요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(Color.captionNeutral)
                .padding(.top, 8)

            if viewModel.optionsLoadState == .loaded && !viewModel.interests.isEmpty {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.interests) { item in
                            InterestButton(
                                title: item.name,
                                isSelected: viewModel.selectedInterests.contains(String(item.id))
                            ) {
                                withAnimation {
                                    viewModel.toggleInterest(String(item.id))
                                }
                            }
                            .animation(.easeInOut, value: viewModel.selectedInterests)
                        }
                    }
                    .padding(.top, 32)
                }
                .scrollIndicators(.hidden)
            } else {
                SelectableOptionsStatusView(state: viewModel.optionsLoadState, onRetry: viewModel.loadOptions)
                Spacer()
            }

            Button(action: {
                viewModel.submitInterests()
            }) {
                Group {
                    if viewModel.isCurationLoading {
                        LoadingDotsView()
                    } else {
                        Text("뉴스레터 추천받기")
                            .font(.hanSansNeo(14, .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    viewModel.isCurationLoading
                        ? Color.primaryBgSubtle
                        : (viewModel.canSubmitInterests ? Color.primaryNormal : Color.lineNeutral)
                )
                .foregroundColor(viewModel.canSubmitInterests ? .white : Color.grayLight)
                .cornerRadius(4)
            }
            .disabled(!viewModel.canSubmitInterests)
            .padding(.top, 34)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .task { try? await viewModel.loadOptions() }
    }
}

struct InterestButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.hanSansNeo(14, .medium))
                .foregroundColor(isSelected ? .primaryNormal : Color.captionNeutral)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.primaryNormal : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
