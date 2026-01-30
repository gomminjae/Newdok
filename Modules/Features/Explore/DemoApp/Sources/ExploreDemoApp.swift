import SwiftUI
import Explore
import DesignSystem
import Shared
import Domain

@main
struct ExploreDemoApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var exploreIntent = ExploreIntent()
    @StateObject private var environment = ExploreDemoEnvironment()

    init() {
        DesignSystemFontFamily.registerAllCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            contentView
                .environmentObject(router)
                .environmentObject(tabSelection)
                .environmentObject(exploreIntent)
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
            ExploreDemoContent(useCase: useCase)
                .environmentObject(router)
                .environmentObject(tabSelection)
                .environmentObject(exploreIntent)
        }
    }
}

private struct ExploreDemoContent: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
    @StateObject private var viewModel: ExploreViewModel

    init(useCase: NewsletterUseCase) {
        _viewModel = StateObject(wrappedValue: ExploreViewModel(useCase: useCase))
    }

    var body: some View {
        ExploreView(viewModel: viewModel)
            .onAppear {
                tabSelection.selectedTab = .explore
                router.root = .explore()
                exploreIntent.trigger = UUID()
            }
    }
}
