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
        self != .check
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
                Task { await viewModel.fetch() }
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
        .popup(isPresented: $isShowPauseAlert) {
            UnsubscribePopupView(brandName: viewModel.detail?.brandName ?? "",
                                 onCancel: {
                isShowPauseAlert = false
                
            },
                                 onConfirm: {
                Task {
                    await viewModel.pause()
                }
                
            })
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.easeInOut) // spring 애니메이션이 버벅일 수 있음
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
                .animation(.easeInOut) // spring 애니메이션이 버벅일 수 있음
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
                                    .stroke(Color(hex: "EBEBEB"))
                            }
                    }
                }
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
                           // ✅ 블러 + 반투명 백그라운드
                           Color.white.opacity(0.6)
                               .background(.ultraThinMaterial) // 또는 .regularMaterial
                               .blur(radius: 8)
                       )
                       .cornerRadius(8)
                       .shadow(
                           color: Color.black.opacity(0.04), // ✅ #000000 4%
                           radius: 8,                         // ✅ Blur
                           x: 0,
                           y: 4                               // ✅ Offset Y
                       )
                       .padding(.horizontal)
                       .offset(y: 15)
                       .padding(.bottom, 12)

                }
            }
            .frame(height: 300)

            Text(detail.detailDescription)
                .font(.hanSansNeo(14, .regular))
                .lineSpacing(4)
                .foregroundStyle(Color(hex: "555555"))
                .padding(.horizontal)
                .padding(.vertical, 12)
                
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
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "EBEBEB")))
                    .padding(.horizontal)
                    .onTapGesture {
                        router.push(.articleDetail(id: "\(article.id)"))
                    }
                }
            }
            .padding(.bottom, 32)
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
                        .stroke(style.border)
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
            print("✅ 구독 신청 API 호출")
        case .check:
            print("⏳ 확인중 상태 - 아무 동작 안 함")
        case .confirmed:
            print("🛑 구독 중지 API 호출")
            
        case .paused:
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
