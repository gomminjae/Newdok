import SwiftUI
import DesignSystem
import Shared
import Foundation
import Combine
import PopupView

public struct EditProfileView: View {
    @State private var userInfo: UserInfo?
    @State private var showEditInterest = false

    @Environment(AppRouter.self) private var router

    @FocusState private var isTextFieldFocused: Bool

    @Environment(MypageViewModel.self) private var viewModel

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("등록하신 정보에 맞춰\n뉴스레터를 추천해드려요")
                .font(.hanSansNeo(18, .bold))
                .padding(.top, 24)
                .padding(.bottom, 40)
                .allowsHitTesting(false)

            // MARK: 닉네임
            EditableRow(
                title: "닉네임",
                text: viewModel.user?.nickname ?? userInfo?.nickname ?? "",
                onEdit: {
                    router.push(.editNickname)
                }
            )

            // MARK: 종사산업
            let industryName = getIndustryName()
            EditableRow(
                title: "종사산업",
                text: industryName,
                placeholder: "산업군을 선택해주세요.",
                onEdit: {
                    router.push(.editIndustry)
                }
            )
            .padding(.top, 24)

            interestSection
                .padding(.top, 24)

            Spacer()
        }
        .onAppear {
            userInfo = viewModel.loadUserInfo()
            if viewModel.user == nil {
                Task {
                    await viewModel.fetchuserInfo()
                    userInfo = viewModel.loadUserInfo()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("RefreshProfile"))) { _ in
            Task {
                await viewModel.fetchuserInfo()
                userInfo = viewModel.loadUserInfo()
            }
        }
        .padding(.horizontal, 20)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { router.pop() } label: {
                    Image(asset: DesignSystemAsset.back)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("프로필 편집")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundColor(.black)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { isTextFieldFocused = false }
                    .foregroundStyle(Color.primaryNormal)
                    .font(.hanSansNeo(17, .medium))
            }
        }
    }

    // MARK: - Helper
    private func getIndustryName() -> String {
        if let id = viewModel.user?.industryId {
            return viewModel.industryName(for: id)
        }
        if let id = userInfo?.industryId {
            return viewModel.industryName(for: id)
        }
        return ""
    }

    private var resolvedInterestNames: [String]? {
        let interestIds: [Int]
        if let interests = viewModel.user?.interests, !interests.isEmpty {
            interestIds = interests.map { $0.id }
        } else if let ids = userInfo?.interestIds, !ids.isEmpty {
            interestIds = ids
        } else {
            return nil
        }

        let names = interestIds.compactMap {
            viewModel.interestName(for: $0)
        }.filter { !$0.isEmpty }
        return names.isEmpty ? nil : names
    }

    @ViewBuilder
    private var interestSection: some View {
        if let names = resolvedInterestNames {
            VStack(alignment: .leading, spacing: 8) {
                Text("관심사")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionNeutral)
                    .allowsHitTesting(false)

                ChipFlowLayout(spacing: 8).callAsFunction {
                    ForEach(names, id: \.self) { item in
                        Text(item)
                            .font(.hanSansNeo(13, .regular))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.lineAlternative, lineWidth: 1)
                            )
                            .allowsHitTesting(false)
                    }

                    Button {
                        router.push(.editInterest)
                    } label: {
                        Image(asset: DesignSystemAsset.linePlus)
                            .renderingMode(.template)
                            .foregroundColor(.primaryNormal)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.primaryNormal, lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Button {
                router.push(.editInterest)
            } label: {
                EditableRow(
                    title: "관심사",
                    text: "",
                    placeholder: "관심사를 선택해주세요."
                )
            }
        }
    }
}
