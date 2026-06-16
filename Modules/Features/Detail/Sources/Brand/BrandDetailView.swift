import SwiftUI
import DesignSystem
import Kingfisher
import DetailDomain
import Shared
import PopupView
import FoundationKit

extension SubscriptionStatus {
    var buttonTitle: String {
        switch self {
        case .initial, .unknown: return "구독하기"
        case .check: return "확인중"
        case .confirmed: return "구독중지"
        case .paused: return "구독재개"
        }
    }

    var isActionable: Bool {
        true
    }

    var style: (background: Color, foreground: Color, border: Color) {
        switch self {
        case .initial, .unknown:
            return (Color.primaryNormal, .white, .clear)
        case .check:
            return (Color.white, Color.captionNeutral, Color.lineNeutral)
        case .confirmed:
            return (Color.white, Color.captionNeutral, Color.lineNeutral)
        case .paused:
            return (.white, Color.primaryNormal, Color.primaryNormal)
        }
    }
}

public struct BrandDetailView: View {
    @State private var viewModel: BrandDetailViewModel
    @Environment(AppRouter.self) private var router
    @Environment(TabSelection.self) private var tabSelection
    @Environment(\.displayScale) private var displayScale
    @Environment(AppState.self) private var appState

    @State private var isShowPauseAlert: Bool = false
    @State private var isShowGuestAlert: Bool = false
    @State private var showSubscribeSheet = false
    @State private var showSubscribeStatePopup = false
    @State private var showCheckSubscribePopup = false
    @State private var hasPresentedSubscribeCheckPopup = false
    @State private var showSignupRequiredPopup = false
    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false

    private var isGuest: Bool { appState.authState == .guest }

    public init(viewModel: BrandDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            if viewModel.isLoading {
                // loading
            } else if let detail = viewModel.detail {
                detailContent(detail)
            } else {
                Text("데이터를 불러올 수 없습니다.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(Color.bgSystem)
        .onAppear {
            if viewModel.detail == nil {
                Task {
                    if isGuest { await viewModel.guestFetch() }
                    else { await viewModel.fetch() }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.pop() } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("뉴스레터 홈")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .popup(isPresented: $isShowPauseAlert) {
            UnsubscribePopupView(brandName: viewModel.detail?.brandName ?? "",
                                 onCancel: { isShowPauseAlert = false },
                                 onConfirm: {
                Task {
                    let didPause = await viewModel.pause()
                    guard didPause else { return }
                    showPauseToast = true
                }
            })
        } customize: {
            $0.type(.default).position(.center).animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true).closeOnTap(false).allowTapThroughBG(false)
        }
        .popup(isPresented: $isShowGuestAlert) {
            SubscribeGuestAlertView(isPresented: $isShowGuestAlert, onSignup: { router.push(.signup) })
        } customize: {
            $0.type(.default).position(.center).animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true).closeOnTap(false).allowTapThroughBG(false)
        }
        .popup(isPresented: $showPauseToast) {
            ToastView(message: "구독이 중지되었습니다.").padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut).closeOnTapOutside(false)
        }
        .popup(isPresented: $showSubscribeToast) {
            ToastView(message: "구독이 재개되었습니다.").padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(1).animation(.easeInOut).closeOnTapOutside(false)
        }
        .popup(isPresented: $showCheckSubscribePopup) {
            CheckIsSubscribeView(
                onClose: { showCheckSubscribePopup = false },
                checkMailbox: {
                    showCheckSubscribePopup = false
                    tabSelection.selectedTab = .home
                    router.resetTo(.tabbar(selectedTab: .home))
                },
                subscribe: {
                    showCheckSubscribePopup = false
                    showSubscribeSheet = true
                }
            )
        } customize: {
            $0.type(.default).position(.center).animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true).closeOnTap(false).allowTapThroughBG(false)
        }
        .popup(isPresented: $showSignupRequiredPopup) {
            SignupRequiredPopupView(
                onSignup: {
                    showSignupRequiredPopup = false
                    showSubscribeSheet = true
                },
                onDismiss: { showSignupRequiredPopup = false }
            )
        } customize: {
            $0.type(.default).position(.center).animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true).closeOnTap(false).allowTapThroughBG(false)
        }
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { router.pop() },
            onRetry: {
                Task {
                    if isGuest { await viewModel.guestFetch() }
                    else { await viewModel.fetch() }
                }
            }
        )
    }

    // MARK: - Detail Content

    @ViewBuilder
    private func detailContent(_ detail: DetailBrandDetail) -> some View {
        VStack(spacing: 0) {
            BrandHeroSection(
                detail: detail,
                isGuest: isGuest,
                isMutating: viewModel.isSubscriptionMutating,
                displayScale: displayScale,
                onSubscribeAction: handleSubscriptionAction
            )

            Text(detail.detailDescription ?? "")
                .font(.hanSansNeo(14, .regular))
                .lineSpacing(4)
                .foregroundStyle(Color.captionBody)
                .padding(.horizontal)
                .padding(.vertical, 24)

            BrandArticleListSection(
                articles: detail.brandArticleList,
                onArticleTap: { id in
                    router.push(.articleDetail(id: id, isPastArticle: true))
                }
            )
            .sheet(isPresented: Binding(
                get: { showSubscribeSheet && !viewModel.requiresSpecialSubscribeFlow },
                set: { showSubscribeSheet = $0 }
            )) {
                SubscribeModalView(title: viewModel.detail?.brandName ?? "", url: viewModel.detail?.subscribeUrl ?? "", email: viewModel.subscribeEmail, name: viewModel.userNickname)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
            .fullScreenCover(isPresented: Binding(
                get: { showSubscribeSheet && viewModel.requiresSpecialSubscribeFlow },
                set: { showSubscribeSheet = $0 }
            )) {
                SubscribeModalView(title: viewModel.detail?.brandName ?? "", url: viewModel.detail?.subscribeUrl ?? "", email: viewModel.subscribeEmail, name: viewModel.userNickname)
            }
            .onChange(of: showSubscribeSheet) { _, newValue in
                if !newValue {
                    if viewModel.shouldShowSubscribeStatePopup {
                        showSubscribeStatePopup = true
                    }
                }
            }
            .popup(isPresented: $showSubscribeStatePopup) {
                SubscribeStatePopupView(
                    onCancel: {
                        viewModel.hideSubscribeStatePopupForToday()
                        showSubscribeStatePopup = false
                    },
                    onConfirm: { showSubscribeStatePopup = false }
                )
            } customize: {
                $0.type(.default).position(.center).animation(.easeInOut)
                    .backgroundColor(Color.black.opacity(0.3))
                    .closeOnTapOutside(true).closeOnTap(false).allowTapThroughBG(false)
            }
        }
        .onAppear {
            presentCheckSubscribePopupIfNeeded(for: detail)
        }
    }

    // MARK: - Actions

    private func handleSubscriptionAction(status: SubscriptionStatus) {
        if isGuest {
            isShowGuestAlert = true
            return
        }
        switch status {
        case .initial, .unknown:
            if viewModel.requiresSpecialSubscribeFlow {
                showSignupRequiredPopup = true
            } else {
                showSubscribeSheet = true
            }
        case .check:
            showCheckSubscribePopup = true
        case .confirmed:
            isShowPauseAlert = true
        case .paused:
            Task {
                let didResume = await viewModel.resume()
                guard didResume else { return }
                showSubscribeToast = true
            }
        }
    }

    private func presentCheckSubscribePopupIfNeeded(for detail: DetailBrandDetail) {
        guard !hasPresentedSubscribeCheckPopup else { return }
        if detail.subscriptionStatus == .check {
            hasPresentedSubscribeCheckPopup = true
            showCheckSubscribePopup = true
        }
    }
}
