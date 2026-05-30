import SwiftUI
import DesignSystem

struct ExploreGuestSection: View {
    let onSignup: () -> Void
    let onLogin: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: DesignSystemAsset.nologin)
                .resizable()
                .frame(width: 280, height: 280)
                .padding(.top, 20)
                .padding(.bottom, 24)
            Text("회원이 되면 뉴스레터를\n간편하게 모아볼 수 있어요!")
                .font(.hanSansNeo(16, .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.captionHeavy)
                .padding(.bottom, 24)

            Button(action: onSignup) {
                Text("회원가입")
                    .font(.hanSansNeo(14, .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.primaryNormal)
                    .cornerRadius(4)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 24)
            }
            HStack {
                Text("이미 계정이 있나요?")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionBody)
                Text("로그인")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.primaryNormal)
                    .underline()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onLogin)
            }
            Spacer()
        }
        .background(Color.bgSystem)
    }
}
