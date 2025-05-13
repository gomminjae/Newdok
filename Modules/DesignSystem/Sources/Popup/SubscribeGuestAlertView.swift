//
//  ArticleDetailView.swift
//  DesignSystem
//
//  Created by 권민재 on 5/12/25.
//  Copyright © 2025 Your Organization Name. All rights reserved.
//

import SwiftUI

public struct SubscribeGuestAlertView: View {
    @Binding var isPresented: Bool
    var onSignup: () -> Void

    public init(isPresented: Binding<Bool>, onSignup: @escaping () -> Void) {
        self._isPresented = isPresented
        self.onSignup = onSignup
    }

    public var body: some View {
        VStack(spacing: 0) {
            // 닫기 버튼
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                   
            
                    // warning 아이콘
                    Image(asset: DesignSystemAsset.warning)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color(hex: "#DADADA"))
                    
                    Spacer().frame(height: 16)
                    
                    Text("구독 신청은 회원가입이 필요해요.")
                        .font(.hanSansNeo(20, .bold))
                        .foregroundColor(Color(hex: "#161616"))
                    
                    Spacer().frame(height: 8)
                    
                    Text("회원가입 후 간편하게\n뉴스레터를 받아보세요!")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundColor(Color(hex: "#565656"))
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 24)
                    
                    Button(action: {
                        isPresented = false
                        onSignup()
                    }) {
                        Text("회원가입")
                            .font(.hanSansNeo(14, .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.primaryNormal)
                            .cornerRadius(4)
                    }
                }
                .padding(24)
                
                // 닫기 버튼은 오른쪽 상단에 overlay로
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(asset: DesignSystemAsset.lineClose)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color(hex: "#000000"))
                            .frame(width: 24, height: 24)
                            .padding(16)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 40)
            
        }
    }
}
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
#Preview {
    StatefulPreviewWrapper(true) { binding in
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea() // 배경 확인용
            SubscribeGuestAlertView(isPresented: binding) {
                print("회원가입 버튼 눌림")
            }
        }
    }
}
