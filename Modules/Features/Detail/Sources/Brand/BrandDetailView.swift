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
    @Environment(\.analyticsIsVisible) private var analyticsVisible
    @Environment(\.scenePhase) private var phase
    @Environment(\.displayScale) private var displayScale

    private let onBack: () -> Void
    private let onSignup: () -> Void
    private let onGoHome: () -> Void
    private let onArticleTap: (String, AnalyticsListContext) -> Void

    @State private var isShowPauseAlert: Bool = false
    @State private var isShowGuestAlert: Bool = false
    @State private var showSubscribeSheet = false
    @State private var showSubscribeStatePopup = false
    @State private var showCheckSubscribePopup = false
    @State private var hasPresentedSubscribeCheckPopup = false
    @State private var showSignupRequiredPopup = false
    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false

    private var isGuest: Bool { AppState.shared.authState == .guest }

    public init(
        viewModel: BrandDetailViewModel,
        onBack: @escaping () -> Void,
        onSignup: @escaping () -> Void,
        onGoHome: @escaping () -> Void,
        onArticleTap: @escaping (String, AnalyticsListContext) -> Void
    ) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onSignup = onSignup
        self.onGoHome = onGoHome
        self.onArticleTap = onArticleTap
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
        .analyticsScreen(.newsletterDetail, from: viewModel.analyticsSource.entryPoint, isVisible: !showSubscribeSheet)
        .onChange(of: viewModel.isLoading) { _, loading in if !loading && analyticsVisible && phase == .active { viewModel.detailViewed() } }
        .onChange(of: analyticsVisible) { _, visible in if visible && phase == .active { viewModel.detailViewed() } }
        .onChange(of: phase) { _, phase in if phase == .active && analyticsVisible { viewModel.detailViewed() } }
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
                Button { onBack() } label: {
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
            SubscribeGuestAlertView(isPresented: $isShowGuestAlert, onSignup: { onSignup() })
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
                    onGoHome()
                },
                subscribe: {
                    showCheckSubscribePopup = false
                    if viewModel.startSubscription() { showSubscribeSheet = true }
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
                    if viewModel.startSubscription() { showSubscribeSheet = true }
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
            onGoBack: { onBack() },
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
                    viewModel.analytics.record(.contentSelected(.article(id: id), list: viewModel.articleList), from: .newsletterDetail)
                    onArticleTap(id, viewModel.articleList)
                }
            )
            .analyticsContentState(detail.brandArticleList.isEmpty ? nil : .ready, list: viewModel.articleList, isVisible: !showSubscribeSheet)
            .sheet(isPresented: Binding(
                get: { showSubscribeSheet && !viewModel.requiresSpecialSubscribeFlow },
                set: { showSubscribeSheet = $0 }
            ), onDismiss: { viewModel.closeSubscription() }) {
                subscriptionModal
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
            .fullScreenCover(isPresented: Binding(
                get: { showSubscribeSheet && viewModel.requiresSpecialSubscribeFlow },
                set: { showSubscribeSheet = $0 }
            ), onDismiss: { viewModel.closeSubscription() }) {
                subscriptionModal
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
            if analyticsVisible && phase == .active { viewModel.detailViewed() }
            presentCheckSubscribePopupIfNeeded(for: detail)
        }
    }

    private var subscriptionModal: some View {
        let session = viewModel.subscriptionSession
        return SubscribeModalView(
            title: viewModel.detail?.brandName ?? "", url: viewModel.detail?.subscribeUrl ?? "",
            email: viewModel.subscribeEmail, name: viewModel.userNickname,
            onPageLoaded: { session?.pageLoaded() }, onPageFailed: { session?.pageFailed($0) }
        )
        .analyticsScreen(.subscribeWeb, from: .newsletterDetail)
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
                if viewModel.startSubscription() { showSubscribeSheet = true }
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
