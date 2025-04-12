//
//  HomeView.swift
//  Newdok
//
//  Created by 권민재 on 2/18/25.
//
import SwiftUI
import DesignSystem
import Shared

public struct HomeView: View {
    let sampleArticles: [Article] = [
        Article(title: "💰 도커스님의 희망 은퇴 연령은?", source: "머니레터", imageName: "moneyletter", isRead: false),
        Article(title: "애플, 9년 만에 내놓은 신제품은?", source: "Daily Byte", imageName: "dailybyte", isRead: false),
        Article(title: "A-Z, 시민단체 보조금 논란", source: "NEWNEEK", imageName: "newneek", isRead: true),
        Article(title: "Apple WWDC24 특집, 지금 바로 확인해보세요!", source: "깨달로그", imageName: "kkaedalogue", isRead: true),
        Article(title: "📈 원운원 그거.. 어떻게 잘하는 건데?", source: "팁스터", imageName: "tipster", isRead: false),
        Article(title: "🧠 ChatGPT는 진짜 사람처럼 생각할까?", source: "AI Insight", imageName: "aiinsight", isRead: false)
    ]
    
    @State private var showCalendar = false
    
    @EnvironmentObject private var router: AppRouter
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(hex: "F5F5F7")
                .ignoresSafeArea()
            
            PullToRefreshView {
                VStack(spacing: 0) {
                    // 헤더
                    HStack {
                        Image(asset: DesignSystemAsset.logo)
                            .padding(.top, 18)
                            .padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            print("검색")
                        }) {
                            Image(asset: DesignSystemAsset.search)
                                .padding(.top, 18)
                                .padding(.trailing, 2.4)
                        }
                        Button(action: {
                            print("알람")
                        }) {
                            Image(asset: DesignSystemAsset.bell)
                                .padding(.top, 18)
                                .padding(.leading, 16)
                                .padding(.trailing, 17.8)
                        }
                    }
                    
                    HStack {
                        Text("5월 23일(수)")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color(hex: "#363636"))
                            .padding(.vertical, 15)
                            .padding(.leading, 24)
                        
                        Spacer()
                        Button(action: {
                            showCalendar.toggle()
                        }) {
                            Image(asset: DesignSystemAsset.lineCalendar)
                                .padding(.vertical, 15)
                                .padding(.trailing, 24)
                        }
                    }
            
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.top, 16)
                    .padding(.horizontal, 8)
                    
                    
                    // 아티클 목록
                    VStack {
                        if sampleArticles.isEmpty {
                            NoDataView(type: .noArticles, buttonAction: {}, loginAction: {})
                        } else {
                            HStack {
                                Text("\(sampleArticles.count)개의 아티클이 도착했어요.")
                                    .font(.hanSansNeo(18, .bold))
                                    .padding(.top, 20)
                                    .padding(.leading, 28)
                                Spacer()
                                Button(action: {
                                    print("새로고침 버튼")
                                }) {
                                    HStack(spacing: 4) {
                                        Image("refresh")
                                        Text("새로고침")
                                            .font(.hanSansNeo(14, .medium))
                                            .foregroundStyle(Color.primaryNormal)
                                    }
                                }
                                .padding(.top, 23)
                                .padding(.trailing, 24)
                            }
                           
                            
                            VStack(spacing: 8) {
                                ForEach(sampleArticles) { article in
                                    ArticleRow(article: article)
                                        .frame(height: 88)
                                }
                            }
                            //.background(Color.red)
                            .padding(.top,20)
                            .padding(.horizontal, 20)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    
                    Spacer()
                }
            } onRefresh: {
                // 당겨서 새로고침 시 실행할 로직
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                // 예: 1.5초 뒤에 데이터 갱신 완료
            }
            .navigationBarHidden(true)
            .popup(isPresented: $showCalendar) {
                CalendarPopupView(isPresented: $showCalendar)
            }
        }
    }
}

// 예시 모델
struct Article: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let imageName: String
    let isRead: Bool
}

// 미리보기
#Preview {
    HomeView()
}
import SwiftUI

/// 커스텀 Pull to Refresh를 구현하기 위한 컨테이너 뷰
/// - content: 실제 표시할 메인 콘텐츠(ScrollView 내용)
/// - onRefresh: 당겨서 새로고침이 트리거될 때 실행할 비동기 작업
struct PullToRefreshView<Content: View>: View {
    let content: () -> Content
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    @State private var pullProgress: CGFloat = 0 // 0 ~ 1 사이 값으로 스피너의 진행도 표현
    
    // 스크롤을 어느 정도 당겼을 때 실제 refresh 동작을 수행할지 임계값
    private let threshold: CGFloat = 80
    
    var body: some View {
        GeometryReader { outerProxy in
            ScrollView(showsIndicators: false) {
                // 스크롤 offset 계산용
                GeometryReader { proxy -> Color in
                    DispatchQueue.main.async {
                        let offset = proxy.frame(in: .named("PullToRefresh")).minY
                        
                        if offset > 0 {
                            // offset / threshold 로 0~1 사이 진행도 계산
                            pullProgress = min(1.0, offset / threshold)
                            
                            // 아직 새로고침 중이 아니고, threshold를 넘겼다면 onRefresh 실행
                            if !isRefreshing && offset > threshold {
                                isRefreshing = true
                                Task {
                                    // 실제 새로고침 작업 실행
                                    await onRefresh()
                                    // 작업 끝난 뒤 상태 리셋
                                    withAnimation {
                                        isRefreshing = false
                                        pullProgress = 0
                                    }
                                }
                            }
                        } else {
                            // 스크롤이 원상태로 돌아오면 진행도 초기화
                            if !isRefreshing {
                                pullProgress = 0
                            }
                        }
                    }
                    return Color.clear
                }
                .frame(height: 0)
                
                // 스피너 (사용자에게 당기는 중임을 시각화)
                if isRefreshing || pullProgress > 0 {
                    CustomSpinner(progress: pullProgress, isRefreshing: isRefreshing)
                        .frame(height: 60)
                }
                
                // 실제 표시할 콘텐츠
                content()
                    .frame(maxWidth: .infinity)
            }
            // 커스텀 좌표공간
            .coordinateSpace(name: "PullToRefresh")
        }
    }
}
struct CustomSpinner: View {
    let progress: CGFloat  // 0 ~ 1
    let isRefreshing: Bool
    
    // 원형 개수
    private let circleCount = 5
    
    var body: some View {
        // 원형 5개를 가로로 배치
        HStack(spacing: 12) {
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .fill(gradient(for: index))
                    .frame(width: 20, height: 20)
                    // 당기는 정도에 따라 크기와 투명도 변화
                    .scaleEffect(scale(for: index))
                    .opacity(opacity(for: index))
            }
        }
        .padding(.top, 8)
        .animation(.easeInOut, value: progress)
        .animation(.easeInOut, value: isRefreshing)
    }
    
    /// index별로 조금씩 다른 파랑 계열 그라디언트
    private func gradient(for index: Int) -> LinearGradient {
        let start = Color.blue.opacity(0.3 + 0.1 * Double(index))
        let end   = Color.blue.opacity(0.7 + 0.05 * Double(index))
        return LinearGradient(
            gradient: Gradient(colors: [start, end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// 당기는 정도(progress)에 따라 크기
    private func scale(for index: Int) -> CGFloat {
        if isRefreshing {
            return 1.0
        } else {
            // progress 0~1 => 0.5~1.0
            return 0.5 + 0.5 * progress
        }
    }
    
    /// 당기는 정도(progress)에 따라 투명도
    private func opacity(for index: Int) -> CGFloat {
        if isRefreshing {
            return 1.0
        } else {
            // progress가 0.5 이상이면 거의 선명, 그 이하면 서서히 투명
            return 0.5 + 0.5 * progress
        }
    }
}
