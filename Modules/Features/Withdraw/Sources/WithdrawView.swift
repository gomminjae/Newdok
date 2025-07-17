import SwiftUI

public struct WithdrawView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 24) {
            Text("회원탈퇴")
                .font(.title)
                .bold()
            Text("정말로 회원을 탈퇴하시겠습니까?\n탈퇴 시 모든 데이터가 삭제됩니다.")
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
            Button(action: {
                // 탈퇴 액션
            }) {
                Text("탈퇴하기")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
} 

#Preview {
    WithdrawView()
}
