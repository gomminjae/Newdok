//
//  VerificationButtonStyle.swift
//  Newdok
//
//  Created by 권민재 on 2/22/25.
//
import SwiftUI

struct VerificationButtonStyle: ButtonStyle {
    var isRequestSent: Bool
    var isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 84)
            .frame(height: 36)
            .font(.system(size: 12, weight: .regular))
            .background(buttonBackground)
            .foregroundColor(buttonForeground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isRequestSent ? Color.blue : Color.clear, lineWidth: 1) // 재전송일 때만 테두리 표시
            )
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0) // 클릭 시 투명도 효과
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
    
    // 배경색 설정
    private var buttonBackground: Color {
        if isDisabled {
            return Color(UIColor.systemGray5) // 비활성화 상태 (연한 회색)
        } else if isRequestSent {
            return Color.white // 재전송 버튼 (흰색 배경)
        } else {
            return Color.blue // 활성화 상태 (파란색 배경)
        }
    }

    // 글자색 설정
    private var buttonForeground: Color {
        if isDisabled {
            return Color(UIColor.systemGray2) // 비활성화 상태 (연한 회색)
        } else if isRequestSent {
            return Color.blue // 재전송 버튼 (파란색 글씨)
        } else {
            return Color.white // 활성화 상태 (흰색 글씨)
        }
    }
}
