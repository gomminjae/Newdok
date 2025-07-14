//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//

import SwiftUI
import DesignSystem
import Shared
import Domain
import PopupView
import Lottie




public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var showCalendar = false
    @State private var calendarDisplayedMonth = Date()
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var tabSelection: TabSelection
    @EnvironmentObject private var exploreIntent: ExploreIntent
    @AppStorage("isGuest") private var isGuest: Bool = false
    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    

    public var body: some View {
        ZStack {
            Color(hex: "F5F5F7").ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    dateBarView
                    contentView
                }
                .background(Color(hex: "#F5F5F7"))
            }
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .onAppear {
            if !isGuest {
                Task { await viewModel.loadToday() }
            }
        }
        .popup(isPresented: $showCalendar) {
                   CalendarPopupView(
                       isPresented: $showCalendar,
                       selectedDate: $viewModel.selectedDate,
                       displayedMonthDate: $calendarDisplayedMonth,
                       dataDays: Binding<Set<Int>>(
                                   get: { viewModel.dataDays },
                                   set: { _ in  }
                               ),
                       onDateSelected: { date in
                           let day = Calendar.current.component(.day, from: date)
                           viewModel.selectDate(day)
                           showCalendar = false
                       },
                       onMonthChanged: { monthDate in
                           Task { await viewModel.loadArticles(for: monthDate) }
                       }
                   )
               } customize: { $0.type(.default).position(.center).animation(.easeInOut).closeOnTap(false).backgroundColor(Color.black.opacity(0.3)) }
    }

    private var headerView: some View {
        HStack {
            Image(asset: DesignSystemAsset.logo)
                .resizable()
                .frame(width: 126, height: 24)
                .padding(.vertical, 18)
                .padding(.leading, 20)
            Spacer()
            HStack(spacing: 16) {
                Button(action: { router.push(.search) }) {
                    Image(asset: DesignSystemAsset.lineSearch)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 18)
                }
                Button(action: { print("알람") }) {
                    Image(asset: DesignSystemAsset.lineBell)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(.vertical, 18)
                        .padding(.trailing, 17.8)
                }
            }
        }
        .background(Color(hex: "#F5F5F7"))
    }

    private var dateBarView: some View {
        HStack(spacing: 0) {
            Text(viewModel.formattedDate)
                .font(.hanSansNeo(16, .bold))
                .foregroundStyle(Color(hex: "#363636"))
                .padding(.leading, 24)
            Spacer()
            Button(action: {
                Task {
                    await viewModel.loadArticles(for: viewModel.selectedDate)
                    showCalendar.toggle()
                }
                
            }) {
                Image(asset: DesignSystemAsset.lineCalendar)
                    .padding(.trailing, 24)
            }
        }
        .frame(height: 52)
        .background(
            Color.white.clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.top, 8)
    }

    @ViewBuilder
    private var contentView: some View {
        VStack {
            switch viewModel.homeState {
            case .none:
                EmptyView()
            case .guest:
                NoDataView(
                    type: .requireSignUp,
                    buttonAction: { router.push(.signup) },
                    loginAction: { router.push(.login) }
                )
            case .noSubscriptions:
                NoDataView(type: .noSubscriptions, buttonAction: {
                    router.resetTo(.tabbar(selectedTab: .explore))
                })
            case .noArticles:
                NoDataView(type: .noArticles, buttonAction: {
                    let weekday = Calendar.current.component(.weekday, from: viewModel.selectedDate)
                    let dayIndex = convertWeekdayToExploreIndex(weekday)
                    exploreIntent.day = dayIndex
                    exploreIntent.selectedTab = 1
                    exploreIntent.trigger = UUID()
                    router.resetTo(.tabbar(selectedTab: .explore))
                    tabSelection.selectedTab = .explore
                })
            case .articles:
                articlesSection
            }
        }
    }

    private var articlesSection: some View {
        VStack {
            HStack {
                Text("\(viewModel.filteredArticles.count)개의 아티클이 도착했어요.")
                    .font(.hanSansNeo(18, .bold))
                    .padding(.top, 20)
                    .padding(.leading, 28)
                Spacer()
                Button(action: {
                    Task { await viewModel.loadToday() }
                }) {
                    HStack(spacing: 4) {
                        Image(asset: DesignSystemAsset.lineReload)
                            .renderingMode(.template)
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                        Text("새로고침")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .padding(.top, 23)
                .padding(.trailing, 24)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.filteredArticles) { article in
                    ArticleRow(article: article)
                        .frame(height: 88)
                        .onTapGesture {
                            router.push(.articleDetail(id: "\(article.articleId)"))
                        }
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(
            Color.white.clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }

    private func convertWeekdayToExploreIndex(_ weekday: Int) -> Int {
        switch weekday {
        case 1: return 7
        case 2: return 1 
        case 3: return 2
        case 4: return 3
        case 5: return 4
        case 6: return 5
        case 7: return 6
        default: return 8
        }
    }
}
