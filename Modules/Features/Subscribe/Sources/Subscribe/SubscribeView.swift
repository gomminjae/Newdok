//
//  SubscribeView.swift
//  Newdok
//
//  Created by 권민재 on 3/3/25.
//
import SwiftUI
import DesignSystem
import Domain
import PopupView

public struct SubscribeView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var viewModel: SubscribeViewModel
    
    
    @State private var showUnsubscribeAlert: Bool = false
    @State private var selectedNewsletter: Newsletter? = nil
    
    
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
                                if selectedTab == 0 {
                                    selectedNewsletter = newsletter
                                    showUnsubscribeAlert = true
//                                    await viewModel.pause(newsletterId: String(newsletter.id ?? 0))
//                                    await viewModel.fetchActive()
                                } else {
                                    await viewModel.resume(newsletterId: String(newsletter.id ?? 0))
                                    await viewModel.fetchPaused()
                                }
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
                await viewModel.fetchActive()
                await viewModel.fetchPaused()
            }
        }
        .popup(isPresented: $showUnsubscribeAlert) {
            if let selected = selectedNewsletter {
                UnsubscribePopupView(
                    brandName: selected.brandName,
                    onCancel: {
                        showUnsubscribeAlert = false
                        selectedNewsletter = nil
                    },
                    onConfirm: {
                        Task {
                            await viewModel.pause(newsletterId: String(selected.id ?? 0))
                            await viewModel.fetchActive()
                            selectedNewsletter = nil
                            showUnsubscribeAlert = false
                        }
                    }
                )
            }
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.spring())
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
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
            Text(selectedTab == 0 ? "총 \(filteredSubscriptions.count)개의 뉴스레터를 구독중이에요." : "\(filteredSubscriptions.count)개의 뉴스레터를 구독 중지했어요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 16)
            Text(selectedTab == 0 ? "구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요." : "구독을 재개하면 다시 아티클을 받아볼 수 있어요")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
        }
    }
}
