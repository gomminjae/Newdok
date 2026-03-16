//
//  CurationView.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain

public struct CurationView: View {
    @ObservedObject private var viewModel: SignupViewModel
    @EnvironmentObject private var router: AppRouter
    
    public init(viewModel: SignupViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isCurationLoading {
                SignupCurationSkeletonView()
            } else {
                loadedContent
            }
        }
        .padding(.horizontal, 24)
    }
}

private extension CurationView {
    var loadedContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.nickname)님을 위한\n맞춤형 뉴스레터가 도착했어요!")
                .font(.hanSansNeo(20, .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
            
            Text("구독한 뉴스레터는 발행일에 맞춰 홈으로 배달해드려요.\n구독하기를 누르면 구독 이메일이 자동으로 복사돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color.captionNeutral)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.recommendedPost, id: \.id) { brand in
                        CurationRow(brand: brand, viewModel: viewModel)
                    }
                }
            }
            .padding(.top, 32)
            .scrollIndicators(.hidden)

            Button {
                viewModel.reset()
                router.resetTo(.tabbar(selectedTab: .home))
            } label: {
                Text("메인으로")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
    }
}
