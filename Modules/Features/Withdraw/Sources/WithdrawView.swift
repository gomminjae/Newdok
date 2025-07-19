import SwiftUI
import DesignSystem
import Shared

public struct WithdrawView: View {
    @StateObject var viewModel: WithdrawViewModel
    @State private var currentPage = 0
    @EnvironmentObject private var router: AppRouter
    @State private var isChecked = false
    @State private var tabSelection = 0
    @State private var withdrawReasons = [false, false, false, false]
    let reasonTexts = [
        "뉴스레터 관리 기능이 부족해서",
        "콘텐츠가 부족해서",
        "더이상 필요가 없어서",
        "기타"
    ]
    
    public init(viewModel: WithdrawViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            TabView(selection: $tabSelection) {
                // 첫 번째 페이지: 탈퇴 안내
                VStack(alignment: .leading, spacing: 0) {
                    Text("'\(viewModel.nickName)'님\n정말 떠나시나요?")
                        .foregroundStyle(Color(hex: "#161616"))
                        .font(.hanSansNeo(20, .bold))
                        .padding(.top, 20)
                    
                    Text("뉴독을 탈퇴하면 활동 내용이 다 사라져요.")
                        .foregroundColor(Color(hex: "#565656"))
                        .font(.hanSansNeo(14, .medium))
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("구독 중인 뉴스레터")
                                .font(.hanSansNeo(16, .bold))
                                .foregroundStyle(Color(hex: "#363636"))
                            Spacer()
                            Text("\(viewModel.newsletterCount)개")
                                .foregroundStyle(Color.primaryNormal)
                                .font(.hanSansNeo(16, .bold))
                        }
                        .cornerRadius(8)
                        
                        HStack {
                            Text("지금까지 수신받은 아티클")
                                .font(.hanSansNeo(16, .bold))
                                .foregroundStyle(Color(hex: "#363636"))
                            Spacer()
                            Text("\(viewModel.articleCount)개")
                                .foregroundStyle(Color.primaryNormal)
                                .font(.hanSansNeo(16, .bold))
                        }
                        .cornerRadius(8)
                    }
                    .padding(.top, 48)
                    
                    HStack(alignment: .top, spacing: 8) {
                        Button(action: {
                            isChecked.toggle()
                        }) {
                            Image(asset: isChecked ?
                                  DesignSystemAsset.check :
                                    DesignSystemAsset.uncheck
                            )
                            .resizable()
                            .frame(width: 20, height: 20)
                        }
                        Text("탈퇴하시면 등록한 정보는 모두 삭제되어 복구할 수 없습니다.")
                            .font(.hanSansNeo(14, .medium))
                            .foregroundStyle(Color(hex: "#161616"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 56)
                    
                    Spacer()
                    
                    Button("계속하기") {
                        withAnimation {
                            tabSelection = 1
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isChecked ? Color.primaryNormal : Color.gray.opacity(0.15))
                    .foregroundColor(isChecked ? .white : Color.gray)
                    .cornerRadius(4)
                    .disabled(!isChecked)
                }
                .padding(.horizontal, 24)
                .padding(.vertical)
                .tag(0)
                
                // 두 번째 페이지: 탈퇴 사유 선택
                VStack(alignment: .leading, spacing: 0) {
                    Text("떠나시는 이유는\n무엇인가요?")
                        .font(.hanSansNeo(20, .bold))
                        .foregroundStyle(Color(hex: "#161616"))
                        .padding(.top, 32)
                    Text("하나 이상의 항목을 선택하시면 탈퇴가 완료돼요.")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#888888"))
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    ForEach(0..<reasonTexts.count, id: \.self) { idx in
                        HStack(spacing: 12) {
                            Button(action: {
                                withdrawReasons[idx].toggle()
                            }) {
                                Image(asset: withdrawReasons[idx] ? DesignSystemAsset.check : DesignSystemAsset.uncheck)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            Text(reasonTexts[idx])
                                .font(.hanSansNeo(14, .medium))
                                .foregroundStyle(Color(hex: "#161616"))
                        }
                        .padding(.vertical, 12)
                    }
                    Spacer()
                    Button("탈퇴완료") {
                        Task { await viewModel.withdraw() }
                        router.resetTo(.login)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(withdrawReasons.contains(true) ? Color.primaryNormal : Color(hex: "#EBEBEB"))
                    .foregroundColor(withdrawReasons.contains(true) ? .white : Color.gray)
                    .font(.hanSansNeo(16, .bold))
                    .cornerRadius(4)
                    .disabled(!withdrawReasons.contains(true))
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
                .padding(.vertical)
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .highPriorityGesture(DragGesture()) // 스와이프 제스처 막기
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { router.pop() }) {
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
}

//#Preview {
//    WithdrawView(viewModel: .init(
//        userUseCase: DummyUserUseCase(),
//        newsletterUseCase: DummyNewsletterUseCase(),
//        articleUseCase: DummyArticleUseCase()
//    ))
//    .environmentObject(AppRouter())
//}
