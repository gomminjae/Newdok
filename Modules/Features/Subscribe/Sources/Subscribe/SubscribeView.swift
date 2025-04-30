//
//  SubscribeView.swift
//  Newdok
//
//  Created by 권민재 on 3/3/25.
//
import SwiftUI
import DesignSystem
import Domain

public struct SubscribeView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var viewModel: SubscribeViewModel

    public init(viewModel: SubscribeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView()

            CustomSegmentedSlider(selectedIndex: $selectedTab, titles: ["구독 중", "구독 중지"])
                .padding(.top, 8)
                .padding(.bottom, 18)
                .padding(.horizontal, 20)

            if filteredSubscriptions.isEmpty {
                EmptySubscriptionView(isSubscribedTab: selectedTab == 0)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        listHeaderView()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)

                        ForEach(filteredSubscriptions, id: \.id) { newsletter in
                            SubscribeRow(newsletter: newsletter, isSubscribed: selectedTab == 0) {
                                print("\(newsletter.brandName) 탭됨")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)

                            
                        }
                    }
                }
                .background(Color(hex: "#F5F5F7"))
            }
        }
        .onAppear {
            Task {
                viewModel.fetchActive()
                viewModel.fetchPaused()
            }
        }
    }

    private var filteredSubscriptions: [Newsletter] {
        selectedTab == 0 ? viewModel.activeNewsletters : viewModel.pausedNewsletters
    }

    private func headerView() -> some View {
        HStack {
            Text("내 구독")
                .font(.hanSansNeo(16, .bold))
                .padding(.leading, 20)

            Spacer()

            Button(action: {}) {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 8)
            }

            Button(action: {}) {
                Image(asset: DesignSystemAsset.lineBell)
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 56)
        .background(.white)
    }

    private func listHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("총 \(filteredSubscriptions.count)개의 뉴스레터를 구독중이에요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
            Text("구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
        }
    }
}
