//
//  CurationRow.swift
//  Newdok
//
//  Created by 권민재 on 2/21/25.
//

import SwiftUI
import AuthDomain
import Kingfisher
import DesignSystem
import Shared

struct CurationRow: View {
    let brand: AuthRecommendedBrand?
    let viewModel: SignupViewModel
    @State private var showSubscribeSheet = false
    
    init(brand: AuthRecommendedBrand? = nil, viewModel: SignupViewModel) {
        self.brand = brand
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                KFImage(URL(string: brand?.imageUrl ?? ""))
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 45 * UIScreen.main.scale, height: 45 * UIScreen.main.scale)))
                    .placeholder {
                        Color.gray.opacity(0.2)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(brand?.name ?? "NEWNEEK")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundStyle(.black)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)

                        Text(brand?.cycle ?? "매주 평일 아침")
                            .font(.hanSansNeo(13))
                            .foregroundStyle(.gray)
                    }
                }

                Spacer()

                Button(action: {
                    // 사용자의 구독 이메일 복사
                    if let userEmail = viewModel.user?.subscribeEmail {
                        UIPasteboard.general.string = userEmail
                    }
                    showSubscribeSheet = true
                }) {
                    Text("구독하기")
                        .font(.hanSansNeo(13, .bold))
                        .foregroundStyle(Color.primaryNormal)
                        .frame(width: 80, height: 32)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.primaryNormal, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(Color.grayBg)

            // 🔹 하단 흰 배경 영역
            VStack(alignment: .leading, spacing: 12) {
                Text(brand?.description ?? "핵심만 꾹꾹 눌러 담은 세상 돌아가는 이야기")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionStrong)

                HStack(spacing: 8) {
                    ForEach(brand?.interests.prefix(3) ?? [], id: \.id) { interest in
                        TagView(text: interest.name)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineNeutral, lineWidth: 1)
        )
        .sheet(isPresented: $showSubscribeSheet) {
            SubscribeModalView(title: brand?.name ?? "", url: brand?.subscribeUrl ?? "", email: UserInfoStore.shared.load()?.subscribeEmail ?? "")
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(.clear)
                .interactiveDismissDisabled(false)
        }
    }
}

struct TagView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.hanSansNeo(12))
            .foregroundStyle(Color.captionStrong)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.lineNeutral, lineWidth: 1)
            )
    }
}
// #Preview {
//    CurationRow()
// }
