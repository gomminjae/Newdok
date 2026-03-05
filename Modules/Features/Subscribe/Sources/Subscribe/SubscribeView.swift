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
import Shared

public struct SubscribeView: View {
    @State private var selectedTab: Int = 0
    @StateObject private var viewModel: SubscribeViewModel

    @State private var showUnsubscribeAlert: Bool = false
    @State private var selectedNewsletter: Newsletter?

    @EnvironmentObject private var router: AppRouter

    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false

    @AppStorage("isGuest") private var isGuest: Bool = false

    public init(viewModel: SubscribeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            CustomSegmentedSlider(selectedIndex: $selectedTab, titles: ["구독 중", "구독 중지"])
                .padding(.top, 8)
                .padding(.bottom, 18)
                .padding(.horizontal, 20)

            contentSection
                .background(Color(hex: "#F5F5F7"))
        }
        .task { await viewModel.loadInitial() }
        .onChange(of: selectedTab) { _, newTab in
            Task {
                await viewModel.refresh(tab: newTab)
            }
        }
        // 팝업/토스트들 기존 그대로…
        .popup(isPresented: Binding(
            get: { showUnsubscribeAlert && selectedNewsletter != nil },
            set: { newValue in
                if !newValue {
                    showUnsubscribeAlert = false
                    selectedNewsletter = nil
                }
            })
        ) {
            if let selected = selectedNewsletter {
                UnsubscribePopupView(
                    brandName: selected.brandName,
                    onCancel: {
                        showUnsubscribeAlert = false
                        selectedNewsletter = nil
                    },
                    onConfirm: {
                        showUnsubscribeAlert = false
                        selectedNewsletter = nil
                        Task {
                            await viewModel.pause(newsletterId: String(selected.id ?? 0))
                            await viewModel.refresh(tab: selectedTab)
                            showPauseToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { showPauseToast = false }
                        }
                    }
                )
            }
        } customize: {
            $0.type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .allowTapThroughBG(false)
        }
        .popup(isPresented: $showPauseToast) {
            ToastView(message: "구독이 중지되었습니다.").padding(.bottom, 106)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut).closeOnTapOutside(false)
        }
        .popup(isPresented: $showSubscribeToast) {
            ToastView(message: "구독이 재개되었습니다.").padding(.bottom, 106)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut).closeOnTapOutside(false)
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onRetry: { Task { await viewModel.loadInitial() } }
        )
    }

    // MARK: - Content
    private var contentSection: some View {
        PullToRefreshView(
            content: {
                contentView
            },
            animationView: {
                AnyView(LoadingView())
            },
            onRefresh: {
                let timeSinceLastRefresh = Date().timeIntervalSince(viewModel.lastRefreshTime)
                if timeSinceLastRefresh < 2.0 {
                    return
                }
                viewModel.lastRefreshTime = Date()
                await viewModel.refresh(tab: selectedTab)
            }
        )
        .background(Color(hex: "#F5F5F7"))
    }

    @ViewBuilder
    private var contentView: some View {
        switch subscribeState {
        case .loading:
            EmptyView()
        case .guest:
            EmptySubscriptionView(isSubscribedTab: selectedTab == 0, isGuest: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            EmptySubscriptionView(isSubscribedTab: selectedTab == 0, isGuest: false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .data:
            subscriptionListView
        }
    }

    private var subscriptionListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            listHeaderView()
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            ForEach(Array(filteredSubscriptions.enumerated()), id: \.element.id) { index, newsletter in
                SubscribeRow(newsletter: newsletter, isSubscribed: selectedTab == 0) {
                    if selectedTab == 0 {
                        selectedNewsletter = newsletter
                        showUnsubscribeAlert = true
                    } else {
                        Task {
                            await viewModel.resume(newsletterId: String(newsletter.id ?? 0))
                            await viewModel.refresh(tab: 0)
                            await viewModel.refresh(tab: 1)
                            showSubscribeToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSubscribeToast = false
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, index == filteredSubscriptions.count - 1 ? 28 : 12)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.3), value: filteredSubscriptions.count)
    }

    private var subscribeState: SubscribeState {
        if !viewModel.initialLoaded {
            return .loading
        }
        if isGuest {
            return .guest
        }
        if filteredSubscriptions.isEmpty {
            return .empty
        }
        return .data
    }

    private var filteredSubscriptions: [Newsletter] {
        // 초기 로딩이 완료되지 않았으면 빈 배열 반환
        guard viewModel.initialLoaded else { return [] }
        return selectedTab == 0 ? viewModel.activeNewsletters : viewModel.pausedNewsletters
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("내 구독")
                .font(.hanSansNeo(18, .bold))
                .foregroundStyle(Color(hex: "161616"))
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

    private func listHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedTab == 0
                 ? "총 \(filteredSubscriptions.count)개의 뉴스레터를 구독중이에요."
                 : "\(filteredSubscriptions.count)개의 뉴스레터를 구독 중지했어요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 30)
            Text(selectedTab == 0
                 ? "구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요."
                 : "구독을 재개하면 다시 아티클을 받아볼 수 있어요")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
        }
    }
}
