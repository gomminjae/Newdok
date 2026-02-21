import SwiftUI
import DesignSystem
import Shared

public struct WithdrawView: View {
    @StateObject private var viewModel: WithdrawViewModel
    @EnvironmentObject private var router: AppRouter
    @State private var isChecked = false
    @State private var tabSelection = 0
    @State private var withdrawReasons = [false, false, false, false]
    
    private let reasonTexts = [
        "뉴스레터 관리 기능이 부족해서",
        "콘텐츠가 부족해서",
        "더이상 필요가 없어서",
        "기타"
    ]
    
    public init(viewModel: WithdrawViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        TabView(selection: $tabSelection) {
            pageOne
                .tag(0)
            
            pageTwo
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .highPriorityGesture(DragGesture())           // 스와이프 방지
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) { bottomBar }   // 하단 고정 버튼
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .enableSwipeBack()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { 
                    if tabSelection == 0 {
                        router.pop()
                    } else {
                        withAnimation { tabSelection = 0 }
                    }
                } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("회원 탈퇴")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
        }
        .onAppear {
            Task { await viewModel.fetchUserInfo() }
        }
    }
    
    // MARK: - 하단 고정 버튼 뷰
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            if tabSelection == 0 {
                Button("계속하기") {
                    withAnimation { tabSelection = 1 }
                }
                .font(.hanSansNeo(14, .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isChecked ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                .foregroundColor(isChecked ? .white : Color(hex: "#BDBDBD"))
                .cornerRadius(4)
                .disabled(!isChecked)
            } else {
                Button("탈퇴완료") {
                    Task {
                        await viewModel.withdraw()
                        router.resetTo(.onboarding)
                    }
                }
                .font(.hanSansNeo(14, .bold))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    withdrawReasons.contains(true)
                        ? Color.primaryNormal
                        : Color(hex: "#EBEBEB")
                )
                .foregroundColor(
                    withdrawReasons.contains(true)
                        ? .white
                        : Color.gray
                )
                .cornerRadius(4)
                .disabled(!withdrawReasons.contains(true))
            }
        }
        .padding(.horizontal, 24)  // 좌우 24
        .padding(.bottom, 20)      // 바텀 20
        
    }
    
    // MARK: - 첫 번째 페이지
    private var pageOne: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 제목
                Text("'\(viewModel.nickName)'님\n정말 떠나시나요?")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundStyle(Color(hex: "#161616"))
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                // 설명
                Text("뉴독을 탈퇴하면 활동 내용이 다 사라져요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#565656"))
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
                // 통계 카드
                VStack(spacing: 16) {
                    HStack {
                        Text("구독 중인 뉴스레터")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color(hex: "#363636"))
                        Spacer()
                        Text("\(viewModel.newsletterCount)개")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.primaryNormal)
                    }
                    
                    HStack {
                        Text("지금까지 수신받은 아티클")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color(hex: "#363636"))
                        Spacer()
                        Text("\(viewModel.articleCount)개")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, 24)
                
                // 체크박스 + 안내문
                HStack(alignment: .top, spacing: 8) {
                    Button { isChecked.toggle() } label: {
                        Image(asset: isChecked
                              ? DesignSystemAsset.allcheck
                              : DesignSystemAsset.uncheck)
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Text("탈퇴하시면 등록한 정보는 모두 삭제되어 복구할 수 없습니다.")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color(hex: "#161616"))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 56)
                .padding(.horizontal, 24)
                
                // 충분한 스크롤 영역 확보
                Spacer(minLength: 0)
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 두 번째 페이지
    private var pageTwo: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 제목
                Text("떠나시는 이유는\n무엇인가요?")
                    .font(.hanSansNeo(20, .bold))
                    .foregroundStyle(Color(hex: "#161616"))
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                
                // 설명
                Text("하나 이상의 항목을 선택하시면 탈퇴가 완료돼요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color(hex: "#888888"))
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // 사유 리스트
                ForEach(reasonTexts.indices, id: \.self) { idx in
                    HStack(spacing: 12) {
                        Button { withdrawReasons[idx].toggle() } label: {
                            Image(asset: withdrawReasons[idx]
                                  ? DesignSystemAsset.allcheck
                                  : DesignSystemAsset.uncheck)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(reasonTexts[idx])
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color(hex: "#161616"))
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 0)
                    .frame(height: 200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// #Preview {
//    WithdrawView(viewModel: .init(
//        userUseCase: DummyUserUseCase(),
//        newsletterUseCase: DummyNewsletterUseCase(),
//        articleUseCase: DummyArticleUseCase()
//    ))
//    .environmentObject(AppRouter())
// }
