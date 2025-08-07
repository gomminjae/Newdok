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
    @State private var selectedNewsletter: Newsletter? = nil
    @State private var isRefreshing = false
    
    @EnvironmentObject private var router: AppRouter
    
    
    //Toast
    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false
    
    @AppStorage("isGuest") private var isGuest: Bool = false 
    
    
    
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

                            PullToRefreshView(
                    content: {
                        if viewModel.isLoading {
                            // 로딩 중에는 빈 뷰
                            Color.clear
                        } else if filteredSubscriptions.isEmpty || isGuest {
                            EmptySubscriptionView(isSubscribedTab: selectedTab == 0, isGuest: isGuest)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                listHeaderView()
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)

                                ForEach(filteredSubscriptions, id: \.id) { newsletter in
                                    SubscribeRow(newsletter: newsletter, isSubscribed: selectedTab == 0) {
                                        if selectedTab == 0 {
                                            selectedNewsletter = newsletter
                                            showUnsubscribeAlert = true
                                        } else {
                                            Task {
                                                await viewModel.resume(newsletterId: String(newsletter.id ?? 0))
                                                await viewModel.fetchPaused()
                                                await viewModel.fetchActive()
                                                showSubscribeToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    
                                                    showSubscribeToast = false
                                                    print("토스트 끝났음")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 12)
                                }
                            }
                            .background(Color(hex: "#F5F5F7"))
                        }
                    },
                animationView: {
                    AnyView(LoadingView())
                },
                onRefresh: {
                    if selectedTab == 0 {
                        // 구독 중 탭: 활성 구독만 새로고침
                        await viewModel.fetchActive()
                    } else {
                        // 구독 중지 탭: 중지된 구독만 새로고침
                        await viewModel.fetchPaused()
                    }
                }
            )
        }
        .onAppear {
            Task {
                await viewModel.fetchActive()
                await viewModel.fetchPaused()
            }
        }
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
                            await viewModel.fetchActive()
                            await viewModel.fetchPaused()
                            showPauseToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showPauseToast = false
                                print("토스트 끝났음")
                            }
                        }
                    }
                )
            }
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut) // spring 애니메이션이 버벅일 수 있음
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
        }
        .popup(isPresented: $showPauseToast) {
            ToastView(message: "구독이 중지되었습니다.")
                .padding(.bottom, 106)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .popup(isPresented: $showSubscribeToast) {
            ToastView(message: "구독이 재개되었습니다.")
                .padding(.bottom, 106)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }

        
    }

    private var filteredSubscriptions: [Newsletter] {
        selectedTab == 0 ? viewModel.activeNewsletters : viewModel.pausedNewsletters
    }

    private func headerView() -> some View {
        HStack {
            Text("내 구독")
                .font(.hanSansNeo(16, .bold))
            Spacer()
            Button(action: {
                router.push(.search)
            }) {
                Image(asset: DesignSystemAsset.lineSearch)
                    .padding(.trailing, 12)
            }
            Button(action: {}) {
                Image(asset: DesignSystemAsset.lineBell)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(height: 56)
        .background(.white)
    }

    private func listHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(selectedTab == 0 ? "총 \(filteredSubscriptions.count)개의 뉴스레터를 구독중이에요." : "\(filteredSubscriptions.count)개의 뉴스레터를 구독 중지했어요.")
                .font(.hanSansNeo(16, .bold))
                .padding(.top, 32)
            Text(selectedTab == 0 ? "구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요." : "구독을 재개하면 다시 아티클을 받아볼 수 있어요")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
        }
    }
}
