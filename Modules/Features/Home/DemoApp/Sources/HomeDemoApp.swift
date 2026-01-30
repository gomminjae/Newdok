import SwiftUI
import Home
import DesignSystem
import Shared
import Domain

@main
struct HomeDemoApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var exploreIntent = ExploreIntent()
    @StateObject private var environment = HomeDemoEnvironment()

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
            HomeDemoContent(useCase: useCase)
                .environmentObject(router)
                .environmentObject(tabSelection)
                .environmentObject(exploreIntent)
        }
    }
}

private struct HomeDemoContent: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
    @StateObject private var viewModel: HomeViewModel

    init(useCase: DefaultHomeBusinessUseCase) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(useCase: useCase))
    }

    var body: some View {
        HomeView(viewModel: viewModel)
            .onAppear {
                tabSelection.selectedTab = .home
                router.root = .home
                exploreIntent.trigger = UUID()
            }
    }
}
