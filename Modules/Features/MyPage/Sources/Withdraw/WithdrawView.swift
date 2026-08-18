import SwiftUI
import DesignSystem
import Shared

public struct WithdrawView: View {
    @State private var viewModel: WithdrawViewModel
    private let onBack: () -> Void
    private let onWithdrawn: () -> Void
    @State private var isChecked = false
    @State private var tabSelection = 0
    @State private var withdrawReasons = [false, false, false, false]
    
    private let reasonTexts = [
        "뉴스레터 관리 기능이 부족해서",
        "콘텐츠가 부족해서",
        "더이상 필요가 없어서",
        "기타"
    ]
    
    public init(viewModel: WithdrawViewModel, onBack: @escaping () -> Void, onWithdrawn: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
        self.onWithdrawn = onWithdrawn
    }
    
    public var body: some View {
        TabView(selection: $tabSelection) {
            pageOne
                .tag(0)
            
            pageTwo
                .tag(1)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) { bottomBar }   // 하단 고정 버튼
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { 
                    if tabSelection == 0 {
                        onBack()
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
        .serverErrorPopup(
            error: $viewModel.currentError,
            onGoBack: { onBack() },
            onRetry: { Task { await viewModel.fetchUserInfo() } }
        )
        .onChange(of: viewModel.withdrawSuccess) { _, success in
            if success {
                onWithdrawn()
            }
        }
    }
    
    // MARK: - 하단 고정 버튼 뷰
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            if tabSelection == 0 {
                Button {
                    withAnimation { tabSelection = 1 }
                } label: {
                    Text("계속하기")
                        .font(.hanSansNeo(14, .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(isChecked ? Color.primaryNormal : Color.lineNeutral)
                        .foregroundColor(isChecked ? .white : Color.grayLight)
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!isChecked)
            } else {
                Button {
                    Task {
                        await viewModel.withdraw()
                    }
                } label: {
                    Text("탈퇴완료")
                        .font(.hanSansNeo(14, .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            withdrawReasons.contains(true)
                                ? Color.primaryNormal
                                : Color.lineNeutral
                        )
                        .foregroundColor(
                            withdrawReasons.contains(true)
                                ? .white
                                : Color.gray
                        )
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!withdrawReasons.contains(true) || viewModel.isWithdrawing)
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
                    .foregroundStyle(Color.captionHeavy)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                // 설명
                Text("뉴독을 탈퇴하면 활동 내용이 다 사라져요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.captionNeutral)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                
                // 통계 카드
                VStack(spacing: 16) {
                    HStack {
                        Text("구독 중인 뉴스레터")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.captionStrong)
                        Spacer()
                        Text("\(viewModel.newsletterCount)개")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.primaryNormal)
                    }
                    
                    HStack {
                        Text("지금까지 수신받은 아티클")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.captionStrong)
                        Spacer()
                        Text("\(viewModel.articleCount)개")
                            .font(.hanSansNeo(16, .bold))
                            .foregroundStyle(Color.primaryNormal)
                    }
                }
                .padding(.top, 48)
                .padding(.horizontal, 24)
                
                // 체크박스 + 안내문
                Button { isChecked.toggle() } label: {
                    HStack(alignment: .top, spacing: 8) {
                        Image(asset: isChecked
                              ? DesignSystemAsset.allcheck
                              : DesignSystemAsset.uncheck)
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text("탈퇴하시면 등록한 정보는 모두 삭제되어 복구할 수 없습니다.")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color.captionHeavy)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
                    .foregroundStyle(Color.captionHeavy)
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                
                // 설명
                Text("하나 이상의 항목을 선택하시면 탈퇴가 완료돼요.")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundColor(Color.grayMuted)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // 사유 리스트
                ForEach(reasonTexts.indices, id: \.self) { idx in
                    Button { withdrawReasons[idx].toggle() } label: {
                        HStack(spacing: 12) {
                            Image(asset: withdrawReasons[idx]
                                  ? DesignSystemAsset.allcheck
                                  : DesignSystemAsset.uncheck)
                                .resizable()
                                .frame(width: 24, height: 24)
                            Text(reasonTexts[idx])
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color.captionHeavy)
                            Spacer()
                        }
                        .frame(height: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
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
//    .environment(AppRouter())
// }
