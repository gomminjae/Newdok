import SwiftUI
import Shared
import DesignSystem

struct AppRootView: View {
    let container: AppContainer
    @Bindable var appRouter: AppRouter

    @State private var launched = false
    @State private var showSessionExpiredPopup = false

    var body: some View {
        ZStack {
            if launched {
                NewDokTabView(container: container, appRouter: appRouter)
                    .transition(.opacity)
            } else {
                container.makeSplashView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .fullScreenCover(item: $appRouter.authRoute) { route in
            AuthFlow(container: container, appRouter: appRouter, root: route)
        }
        .task {
            guard !launched, !Task.isCancelled else { return }

            if TokenStore.shared.hasValidToken {
                AppState.shared.login()
            } else {
                AppState.shared.logout()
                appRouter.navigate(to: .auth(.onboarding))
            }

            withAnimation(.easeInOut(duration: AppConstants.Animation.default)) {
                launched = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveUnauthorized)) { _ in
            Task { await container.signOut() }
            AppState.shared.logout()
            showSessionExpiredPopup = true
        }
        .sessionExpiredPopup(isPresented: $showSessionExpiredPopup) {
            appRouter.navigate(to: .auth(.login))
        }
    }
}
