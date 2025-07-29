//
//  SubscribeViewResult.swift
//  Subscribe
//
//  Created by AI Assistant on 1/14/25.
//

import SwiftUI
import DesignSystem
import Domain
import PopupView
import Shared

public struct SubscribeViewResult: View {
    @State private var selectedTab: Int = 0
    @StateObject private var viewModel: SubscribeViewModelResult
    
    @State private var showUnsubscribeAlert: Bool = false
    @State private var selectedNewsletter: Newsletter? = nil
    
    @EnvironmentObject private var router: AppRouter
    
    // Toast
    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false
    @State private var toastMessage: String = ""
    
    @AppStorage("isGuest") private var isGuest: Bool = false 
    
    public init(viewModel: SubscribeViewModelResult) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerView()

            CustomSegmentedSlider(selectedIndex: $selectedTab, titles: ["구독 중", "구독 중지"])
                .padding(.top, 8)
                .padding(.bottom, 18)
                .padding(.horizontal, 20)

            if viewModel.isLoading {
                loadingView
            } else if filteredSubscriptions.isEmpty || isGuest {
                EmptySubscriptionView(isSubscribedTab: selectedTab == 0, isGuest: isGuest)
            } else {
                ScrollView {
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
                                        let result = await viewModel.resume(newsletterId: String(newsletter.id))
                                        await handleSubscriptionResult(result, newsletter: newsletter, action: "구독 재개")
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchActive()
                await viewModel.fetchPaused()
            }
        }
        .alert("구독 중지", isPresented: $showUnsubscribeAlert) {
            Button("취소", role: .cancel) {}
            Button("중지") {
                guard let newsletter = selectedNewsletter else { return }
                Task {
                    let result = await viewModel.pause(newsletterId: String(newsletter.id))
                    await handleSubscriptionResult(result, newsletter: newsletter, action: "구독 중지")
                }
                selectedNewsletter = nil
            }
        } message: {
            Text("정말로 이 뉴스레터 구독을 중지하시겠습니까?")
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                // 에러 메시지는 자동으로 초기화됨
            }
            Button("다시 시도") {
                Task {
                    await viewModel.fetchActive()
                    await viewModel.fetchPaused()
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .popup(isPresented: $showSubscribeToast) {
            ToastView(message: toastMessage)
                .padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(2).animation(.easeInOut).closeOnTapOutside(false)
        }
        .popup(isPresented: $showPauseToast) {
            ToastView(message: toastMessage)
                .padding(.bottom, 50)
        } customize: {
            $0.type(.toast).position(.bottom).autohideIn(2).animation(.easeInOut).closeOnTapOutside(false)
        }
    }
    
    private var filteredSubscriptions: [Newsletter] {
        selectedTab == 0 ? viewModel.activeNewsletters : viewModel.pausedNewsletters
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                .scaleEffect(1.2)
            
            Text("구독 정보를 불러오고 있습니다...")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func headerView() -> some View {
        HStack {
            Text("구독 관리")
                .font(.hanSansNeo(20, .bold))
                .foregroundStyle(Color(hex: "161616"))
            
            Spacer()
            
            if viewModel.isLoading || viewModel.isSubscriptionLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryNormal))
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private func listHeaderView() -> some View {
        HStack {
            Text("총 \(filteredSubscriptions.count)개")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "565656"))
            
            Spacer()
        }
    }
    
    private func handleSubscriptionResult(_ result: AppResult<Void>, newsletter: Newsletter, action: String) async {
        await result
            .onSuccess { _ in
                await MainActor.run {
                    toastMessage = "\(newsletter.brandName) \(action)되었습니다"
                    if action.contains("중지") {
                        showPauseToast = true
                    } else {
                        showSubscribeToast = true
                    }
                }
            }
            .onFailure { error in
                await MainActor.run {
                    toastMessage = "\(action) 실패: \(error.localizedDescription)"
                    showPauseToast = true
                }
            }
    }
}

// MARK: - Supporting Views
private struct CustomSegmentedSlider: View {
    @Binding var selectedIndex: Int
    let titles: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<titles.count, id: \.self) { index in
                Button(action: {
                    selectedIndex = index
                }) {
                    Text(titles[index])
                        .font(.hanSansNeo(14, selectedIndex == index ? .bold : .medium))
                        .foregroundColor(selectedIndex == index ? Color(hex: "161616") : Color(hex: "999999"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(selectedIndex == index ? Color.white : Color.clear)
                                .cornerRadius(6)
                        )
                }
            }
        }
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(6)
    }
}

private struct EmptySubscriptionView: View {
    let isSubscribedTab: Bool
    let isGuest: Bool
    
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "CCCCCC"))
            
            Text(title)
                .font(.hanSansNeo(16, .medium))
                .foregroundStyle(Color(hex: "161616"))
            
            Text(subtitle)
                .font(.hanSansNeo(14, .regular))
                .foregroundStyle(Color(hex: "565656"))
                .multilineTextAlignment(.center)
            
            Button(buttonTitle) {
                if isGuest {
                    router.push(.login)
                } else {
                    router.resetTo(.tabbar(selectedTab: .explore))
                }
            }
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.primaryNormal)
            .cornerRadius(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iconName: String {
        if isGuest {
            return "person.circle"
        } else {
            return isSubscribedTab ? "envelope" : "envelope.open"
        }
    }
    
    private var title: String {
        if isGuest {
            return "로그인이 필요합니다"
        } else {
            return isSubscribedTab ? "구독중인 뉴스레터가 없습니다" : "중지된 구독이 없습니다"
        }
    }
    
    private var subtitle: String {
        if isGuest {
            return "로그인하고 관심있는 뉴스레터를\n구독해보세요"
        } else {
            return isSubscribedTab ? 
                "관심있는 뉴스레터를 구독하고\n매일 새로운 소식을 받아보세요" :
                "중지된 구독이 없습니다.\n언제든지 구독을 중지하고 재개할 수 있습니다"
        }
    }
    
    private var buttonTitle: String {
        if isGuest {
            return "로그인"
        } else {
            return "뉴스레터 둘러보기"
        }
    }
}

private struct SubscribeRow: View {
    let newsletter: Newsletter
    let isSubscribed: Bool
    let onButtonTap: () -> Void
    
    @EnvironmentObject private var router: AppRouter
    
    var body: some View {
        Button {
            router.push(.brandDetail(id: String(newsletter.id)))
        } label: {
            HStack(spacing: 12) {
                // 뉴스레터 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(newsletter.brandName)
                        .font(.hanSansNeo(16, .medium))
                        .foregroundStyle(Color(hex: "161616"))
                        .multilineTextAlignment(.leading)
                    
                    Text(newsletter.introduction)
                        .font(.hanSansNeo(14, .regular))
                        .foregroundStyle(Color(hex: "565656"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(dayText)
                            .font(.hanSansNeo(12, .medium))
                            .foregroundStyle(Color(hex: "2866D3"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "E8F1FF"))
                            .cornerRadius(12)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // 액션 버튼
                Button(action: onButtonTap) {
                    Text(isSubscribed ? "중지" : "재개")
                        .font(.hanSansNeo(12, .medium))
                        .foregroundColor(isSubscribed ? Color(hex: "E32727") : Color.primaryNormal)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSubscribed ? Color(hex: "FFF2F2") : Color(hex: "E8F1FF"))
                        .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dayText: String {
        let days = ["", "월", "화", "수", "목", "금", "토", "일"]
        return newsletter.deliveryDays.compactMap { days[safe: $0] }.joined(separator: ", ")
    }
}

private struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.hanSansNeo(14, .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
    }
}

// MARK: - Array Extension
private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 