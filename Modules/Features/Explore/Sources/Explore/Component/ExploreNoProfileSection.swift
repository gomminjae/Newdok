import SwiftUI
import DesignSystem

struct ExploreNoProfileSection: View {
    let nickname: String
    let onEditProfile: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Image(asset: DesignSystemAsset.nologin)
                    .resizable()
                    .frame(width: 280, height: 280)
                    .padding(.bottom, 24)

                Text("프로필을 등록해 주세요.")
                    .font(.hanSansNeo(16, .bold))
                    .foregroundStyle(Color.captionHeavy)
                    .padding(.bottom, 4)

                Text("\(nickname)님만을 위한 뉴스레터를 찾아드릴게요!")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionBody)
                    .padding(.bottom, 24)

                Button(action: onEditProfile) {
                    Text("프로필 등록하기")
                        .font(.hanSansNeo(14, .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.primaryNormal)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 24)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgSystem)
    }
}
