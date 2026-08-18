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
            if !launched {
                container.makeSplashView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(1)
            }

            NewDokTabView(container: container, appRouter: appRouter)
                .opacity(launched ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: launched)
        }
        .fullScreenCover(item: $appRouter.authRoute) { route in
            AuthFlow(container: container, appRouter: appRouter, root: route)
        }
        .task {
            do {
                try await container.loadExploreOptions()
            } catch {
                print("Failed to load options: \(error)")
            }

            do {
                try await Task.sleep(nanoseconds: UInt64(AppConstants.Duration.splash * 1_000_000_000))
            } catch {
                return
            }

            if TokenStore.shared.hasValidToken {
                AppState.shared.login()
            } else {
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
