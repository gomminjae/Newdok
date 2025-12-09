import SwiftUI
import Explore
import Shared
import Domain

struct ExploreDemoRootView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @StateObject private var viewModel: ExploreViewModel

    init(useCase: NewsletterUseCase) {
        _viewModel = StateObject(wrappedValue: ExploreViewModel(useCase: useCase))
    }

    var body: some View {
        NavigationStack(path: Binding(
            get: { router.path },
            set: { router.path = $0 }
        )) {
            ExploreView(viewModel: viewModel)
                .navigationDestination(for: AppRoute.self, destination: DemoDestinationView.init)
        }
        .onAppear {
            tabSelection.selectedTab = .explore
            router.root = .explore()
        }
    }
}

private struct DemoDestinationView: View {
    let route: AppRoute

    var body: some View {
        VStack(spacing: 16) {
            Text("Route not implemented in demo")
                .font(.headline)
            Text("\(String(describing: route))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
