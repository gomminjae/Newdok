//
//  BrandDetailView.swift
//  Detail
//
//  Created by 권민재 on 5/7/25.
//

import SwiftUI
import DesignSystem
import Kingfisher
import Domain
import Shared
import PopupView

struct RoundedCorner: Shape {
    var radius: CGFloat = 0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let p = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(p.cgPath)
    }
}

enum SubscriptionStatus: String {
    case initial = "INITIAL"
    case check = "CHECK"
    case confirmed = "CONFIRMED"
    case paused = "PAUSED"

    var buttonTitle: String {
        switch self {
        case .initial: return "구독하기"
        case .check: return "확인중"
        case .confirmed: return "구독중지"
        case .paused: return "구독재개"
        }
    }

    var isActionable: Bool {
        true // 모든 상태에서 버튼 활성화
    }

    var style: (background: Color, foreground: Color, border: Color) {
        switch self {
        case .initial:
            return (Color.primaryNormal, .white, .clear)
        case .check:
            return (Color.white, Color(hex: "565656"), Color(hex: "ebebeb"))
        case .confirmed:
            return (Color.white, Color(hex: "565656"), Color(hex: "ebebeb"))
        case .paused:
            return (.white, Color.primaryNormal, Color.primaryNormal)
        }
    }
}



public struct BrandDetailView: View {
    @StateObject private var viewModel: BrandDetailViewModel
    @EnvironmentObject private var router: AppRouter
    
    @State private var isShowPauseAlert: Bool = false
    @State private var isShowGuestAlert: Bool = false
    
    @AppStorage("isGuest") private var isGuest = false
    
    @State private var showSubscribeSheet = false
    @State private var showSubscribeStatePopup = false
    @State private var showCheckSubscribePopup = false
    
    
    
    //Toast
    @State private var showSubscribeToast: Bool = false
    @State private var showPauseToast: Bool = false

    
    public init(viewModel: BrandDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
      
    }

    public var body: some View {
        ScrollView {
            
            if viewModel.isLoading {
                //ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let detail = viewModel.detail {
                detailContent(detail)
            } else {
                Text("데이터를 불러올 수 없습니다.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(Color(hex: "F5F5F7"))
        .onAppear {
            
            if viewModel.detail == nil {
                if isGuest {
                    Task { await viewModel.guestFetch() }
                } else {
                    Task { await viewModel.fetch() }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.pop()
                } label: {
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
                                 onCancel: {
                isShowPauseAlert = false
                
            },
                                 onConfirm: {
                Task {
                    await viewModel.pause()
                    viewModel.detail?.isSubscribed = SubscriptionStatus.paused.rawValue
                    showPauseToast = true
                }
                
            })
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
        }
        .popup(isPresented: $isShowGuestAlert) {
            SubscribeGuestAlertView(isPresented: $isShowGuestAlert,
                                    onSignup: {
                router.push(.signup)
            }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
        }
        .popup(isPresented: $showPauseToast) {
            ToastView(message: "구독이 중지되었습니다.")
                .padding(.bottom, 50)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .popup(isPresented: $showSubscribeToast) {
            ToastView(message: "구독이 재개되었습니다.")
                .padding(.bottom, 50)
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .autohideIn(1)
                .animation(.easeInOut)
                .closeOnTapOutside(false)
        }
        .popup(isPresented: $showCheckSubscribePopup) {
            CheckSubscribeView(
                onConfirmEmail: {
                    showCheckSubscribePopup = false
                    // 홈으로 라우팅
                    router.resetTo(.tabbar(selectedTab: .home))
                }
            )
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut)
                .backgroundColor(Color.black.opacity(0.3))
                .closeOnTapOutside(true)
        }
    }

    @ViewBuilder
    private func detailContent(_ detail: BrandDetail) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                KFImage(URL(string: detail.imageUrl))
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .overlay(
                           LinearGradient(
                               gradient: Gradient(stops: [
                                   .init(color: Color.black.opacity(0.0), location: 0.0),
                                   .init(color: Color.black.opacity(0.06), location: 1.0)
                               ]),
                               startPoint: .top,
                               endPoint: .bottom
                           )
                       )
                       .mask( // 🔻 하단 모서리만 12
                           RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                       )
                       .clipped()
                       .shadow( // 🔻 Elevation 2_Bottom
                               color: Color(red: 0x19/255, green: 0x19/255, blue: 0x19/255).opacity(0.04),
                               radius: 4, x: 0, y: 2
                           )
                
                // 구독 확인 중 오버레이
                if let status = SubscriptionStatus(rawValue: detail.isSubscribed ?? ""), status == .check {
                    Color(hex: "25242C").opacity(0.6) 
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .mask(
                            RoundedCorner(radius: 12, corners: [.bottomLeft, .bottomRight])
                        )
                        .overlay(
                            Text("구독 확인 중")
                                .font(.hanSansNeo(16, .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        )
                }
                

                HStack(spacing: 4) {
                    ForEach(detail.interests.prefix(3), id: \..id) { interest in
                        Text(interest.name)
                            .font(.hanSansNeo(11, .medium))
                            .foregroundStyle(Color(hex: "363636"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "ffffff").opacity(0.61))
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color(hex: "EBEBEB"), lineWidth: 1.5)
                            }
                    }
                    
                    Spacer()
                    
           
                    if let status = SubscriptionStatus(rawValue: detail.isSubscribed ?? ""), status == .confirmed {
                        Text("구독중")
                            .font(.hanSansNeo(11, .medium))
                            .foregroundStyle(Color.white)
                            .frame(width: 50, height: 26)
                            .background(Color(hex: "#5184DB"))
                            .clipShape(Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(Color.primaryNormal, lineWidth: 1.5)
                            }
                    }
                }
                .padding(.trailing, 16)
                .padding(.top, 12)
                .padding(.leading, 16)

                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(detail.brandName)
                                .font(.hanSansNeo(16, .bold))

                            HStack(spacing: 4) {
                                Image(asset: DesignSystemAsset.lineClock)
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundStyle(Color(hex: "565656"))
                                    .frame(width: 20, height: 20)

                                Text(detail.publicationCycle)
                                    .font(.hanSansNeo(12, .medium))
                                    .foregroundStyle(Color(hex: "565656"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer()
                        if let status = SubscriptionStatus(rawValue: viewModel.detail?.isSubscribed ?? "") {
                            subscribeButton(status: status)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 21)
                    .background(
                        ZStack {
                            // Background Blur
                            Color.clear
                                //.background(.regularMaterial) // ultraThin보다 진함
                                .blur(radius: 8)

                            // White overlay with 60% opacity
                            Color.white.opacity(0.6)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(
                        color: Color.black.opacity(0.04),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                    .padding(.horizontal)
                    .offset(y: 20)
                    .padding(.bottom, 12)

                }
            }
            .frame(height: 300)

            Text(detail.detailDescription)
                .font(.hanSansNeo(14, .regular))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: "555555"))
                .padding(.horizontal)
                .padding(.vertical, 24)
                
            VStack(alignment: .leading, spacing: 8) {
                Text("지난 아티클 보기")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundStyle(Color(hex: "#565656"))
                    .padding(.leading, 28)
                    .padding(.top, 20)

                ForEach(detail.brandArticleList) { article in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title)
                            .font(.hanSansNeo(14, .bold))
                            .foregroundStyle(Color(hex: "363636"))
                            .padding(.bottom, 4)

                        HStack {
                            Text(article.date.prefix(10))
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color(hex: "565656"))

                            Divider()

                            Text(extractTime(from: article.date))
                                .font(.hanSansNeo(12, .medium))
                                .foregroundColor(Color(hex: "565656"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "EBEBEB"), lineWidth: 1.5))
                    .padding(.horizontal)
                    .onTapGesture {
                        router.push(.articleDetail(id: "\(article.id)"))
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 32)
            .sheet(isPresented: $showSubscribeSheet) {
                SubscribeModalView(title: viewModel.detail?.brandName ?? "", url: viewModel.detail?.subscribeUrl ?? "")
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.clear)
                    .interactiveDismissDisabled(false)
            }
            .onChange(of: showSubscribeSheet) { _, newValue in
                // 구독 시트가 닫힐 때 팝업 띄우기
                if !newValue {
                    // 오늘 하루 보지 않기 설정 확인
                    if TokenStorage.shouldShowSubscribeStatePopup {
                        showSubscribeStatePopup = true
                    }
                }
            }
            .popup(isPresented: $showSubscribeStatePopup) {
                SubscribeStatePopupView(
                    onCancel: {
                        TokenStorage.hideSubscribeStatePopupForToday()
                        showSubscribeStatePopup = false
                    },
                    onConfirm: {
                        showSubscribeStatePopup = false
                    }
                )
            } customize: {
                $0
                    .type(.default)
                    .position(.center)
                    .animation(.easeInOut)
                    .backgroundColor(Color.black.opacity(0.3))
                    .closeOnTapOutside(true)
            }
        }
    }

    
    private func subscribeButton(status: SubscriptionStatus) -> some View {
        let style = status.style

        return Button(action: {
            handleSubscriptionAction(status: status)
        }) {
            Text(status.buttonTitle)
                .frame(width: 95, height: 40)
                .font(.system(size: 14, weight: .semibold))
                .background(style.background)
                .foregroundColor(style.foreground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(style.border, lineWidth: 1.5)
                )
        }
        .disabled(!status.isActionable)
    }
    
    private func handleSubscriptionAction(status: SubscriptionStatus) {
        if isGuest {
            isShowGuestAlert = true
            return
        }
        
        switch status {
        case .initial:
            showSubscribeSheet = true
            print("✅ 구독 신청 API 호출")
        case .check:
            showCheckSubscribePopup = true
            print("⏳ 확인중 상태 - CheckSubscribeView 팝업 표시")
        case .confirmed:
            isShowPauseAlert = true
            
        case .paused:
            Task {
                await viewModel.resume() // 구독 재개 처리
                viewModel.detail?.isSubscribed = SubscriptionStatus.confirmed.rawValue
                showSubscribeToast = true
            }
            print("✅ 구독 재개 API 호출")
        }
    }


    
    
    func extractTime(from isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fallbackFormatter = ISO8601DateFormatter() // for when fractional seconds not present
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        let date = isoFormatter.date(from: isoString) ?? fallbackFormatter.date(from: isoString)

        guard let date = date else { return "" }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "a h:mm"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        return timeFormatter.string(from: date)
    }

}
