//
//  CustomTextFieldModifier.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//
import SwiftUI

struct CustomTextFieldModifier: ViewModifier {
    var icon: String
    
    func body(content: Content) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)

            content
                .foregroundColor(.primary) 
                .padding(.vertical, 12)
            
        }
        .padding(.horizontal)
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}
extension View {
    func customTextFieldStyle(icon: String) -> some View {
        self.modifier(CustomTextFieldModifier(icon: icon))
    }
}



import SwiftUI

struct PasswordFieldModifier: ViewModifier {
    @Binding var isSecure: Bool
    
    func body(content: Content) -> some View {
        HStack {
            Image("lock")
                .foregroundColor(.gray)
            
            content
            Button(action: {
                isSecure.toggle()
            }) {
                Image(isSecure ? "_Line Close Eye" : "Line Eye")
                    .foregroundColor(.blue)
            }
        }
        .padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "DADADA"), lineWidth: 1)
        )
    }
}

// Modifier를 쉽게 적용하기 위한 Extension
extension View {
    func passwordFieldStyle(isSecure: Binding<Bool>) -> some View {
        self.modifier(PasswordFieldModifier(isSecure: isSecure))
    }
}

