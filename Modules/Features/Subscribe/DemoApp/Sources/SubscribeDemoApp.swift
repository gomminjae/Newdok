import SwiftUI
import Subscribe
import DesignSystem
import Shared
import Domain

@main
struct SubscribeDemoApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var environment = SubscribeDemoEnvironment()

    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            contentView
                .environmentObject(router)
                .environmentObject(tabSelection)
                .environmentObject(ToastCenter.shared)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch environment.state {
        case .loading:
            ProgressView("로그인 중...")
                .font(.hanSansNeo(16, .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
        case .failed(let message):
            VStack(spacing: 16) {
                Text("자동 로그인에 실패했습니다.")
                    .font(.hanSansNeo(18, .bold))
                Text(message)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(.captionAssistive)
                    .multilineTextAlignment(.center)
                Button("다시 시도하기") {
                    environment.retry()
                }
                .font(.hanSansNeo(14, .bold))
                .padding(.vertical, 10)
                .padding(.horizontal, 24)
                .background(Color.primaryNormal)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        case .loaded(let useCase):
            SubscribeDemoContent(useCase: useCase)
                .environmentObject(router)
                .environmentObject(tabSelection)
        }
    }
}

private struct SubscribeDemoContent: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @StateObject private var viewModel: SubscribeViewModel

    init(useCase: NewsletterUseCase) {
        _viewModel = StateObject(wrappedValue: SubscribeViewModel(useCase: useCase))
    }

    var body: some View {
        SubscribeView(viewModel: viewModel)
            .onAppear {
                tabSelection.selectedTab = .subscribe
                router.root = .tabbar(selectedTab: .subscribe)
            }
    }
}
