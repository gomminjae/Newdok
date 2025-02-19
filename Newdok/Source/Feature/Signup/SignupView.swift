//
//  SignupView.swift
//  Newdok
//
//  Created by 권민재 on 2/15/25.
//

import SwiftUI

struct SignupView: View {
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var phoneNumber: String = ""
    
    @State private var currentStep: Double = 0.3
    @Namespace private var scrollNAmeSpace
    
    
    var body: some View {
        VStack {
            ProgressView(value: Double(currentStep), total: 3)
                .progressViewStyle(.linear)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 32) {
                        PhoneVerificationView()
                    }
                    .padding()
                }
                .onChange(of: currentStep) { newStep in
                    withAnimation {
                        proxy.scrollTo(newStep, anchor: .top) // 다음 단계로 스크롤 이동
                    }
                }
            }
        }
        .padding(.top, 20)
        .navigationTitle("회원가입")
        
    }
    private func nextStep() {
        if currentStep < 2 {
            currentStep += 1
        }
    }
}
struct StepView<Content: View>: View {
    var step: Int
    var title: String
    var content: Content

    init(step: Int, title: String, @ViewBuilder content: () -> Content) {
        self.step = step
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)

            content
        }
    }
}

#Preview {
    SignupView()
}
