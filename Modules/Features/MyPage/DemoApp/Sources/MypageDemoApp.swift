import SwiftUI
import Mypage
import DesignSystem
import Shared
import Domain

@main
struct MypageDemoApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var tabSelection = TabSelection()
    @StateObject private var environment = MypageDemoEnvironment()

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
            MypageDemoContent(useCase: useCase)
                .environmentObject(router)
                .environmentObject(tabSelection)
        }
    }
}

private struct MypageDemoContent: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @StateObject private var viewModel: MypageViewModel

    init(useCase: UserUseCase) {
        _viewModel = StateObject(wrappedValue: MypageViewModel(useCase: useCase))
    }

    var body: some View {
        MypageView(viewModel: viewModel)
            .environmentObject(router)
            .onAppear {
                tabSelection.selectedTab = .profile
                router.root = .tabbar(selectedTab: .profile)
                Task { await viewModel.fetchuserInfo() }
            }
    }
}
