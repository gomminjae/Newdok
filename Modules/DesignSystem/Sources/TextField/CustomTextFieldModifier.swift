//
//  CustomTextFieldModifier.swift
//  Newdok
//
//  Created by 권민재 on 3/6/25.
//
import SwiftUI


public struct CustomTextFieldModifier: ViewModifier {
    
    
    @FocusState private var isFocused: Bool
    
    public init() {}
       
    
    public func body(content: Content) -> some View {
        HStack {
            Image("Line User")
                .foregroundColor(.gray)
            

            content
                .foregroundColor(.primary) 
                .padding(.vertical, 12)
                .focused($isFocused)
            
        }
        .padding(.horizontal)
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isFocused ? Color.primary : Color.gray.opacity(0.5), lineWidth: 1)
        )
        
    }
}
public extension View {
    func customTextFieldStyle() -> some View {
        self.modifier(CustomTextFieldModifier())
    }
}


public struct PasswordFieldModifier: ViewModifier {
    
    @Binding var isSecure: Bool
    @FocusState private var isFocused: Bool
    
    public init(isSecure: Binding<Bool>) {
        self._isSecure = isSecure
    }
    
    public func body(content: Content) -> some View {
        HStack {
            Image("Line Lock")
                .foregroundColor(.gray)
            
            content
                .focused($isFocused)
            Button(action: {
                isSecure.toggle()
            }) {
                Image(isSecure ? "Line Close Eye" : "Line Eye")
                    .renderingMode(.template)
                    .foregroundColor(isFocused ? Color.primary : Color(hex: "#363636"))
                
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(isFocused ? Color.primary : Color.gray.opacity(0.5), lineWidth: 1)
        }
        
    }
}

public extension View {
    func passwordFieldStyle(isSecure: Binding<Bool>) -> some View {
        self.modifier(PasswordFieldModifier(isSecure: isSecure))
    }
}

