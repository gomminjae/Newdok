//
//  SignupCurationSkeletonView.swift
//  Signup
//
//  Created by 권민재 on 6/7/25.
//

import SwiftUI
import DesignSystem

struct SignupCurationSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SkeletonBlock(width: 240, height: 24)
                .padding(.top, 24)
            SkeletonBlock(width: 180, height: 24)
                .padding(.top, 8)
            
            SkeletonBlock(width: 280, height: 16)
                .padding(.top, 28)
            SkeletonBlock(width: 220, height: 16)
                .padding(.top, 6)
            
            VStack(spacing: 16) {
                ForEach(0..<2, id: \.self) { _ in
                    CurationSkeletonCard()
                }
            }
            .padding(.top, 32)
            
            SkeletonBlock(height: 48, cornerRadius: 10)
                .padding(.top, 32)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CurationSkeletonCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .overlay(
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        SkeletonBlock(width: 48, height: 48, cornerRadius: 8)
                        VStack(alignment: .leading, spacing: 8) {
                            SkeletonBlock(width: 120, height: 14, cornerRadius: 6)
                            SkeletonBlock(width: 160, height: 12, cornerRadius: 6)
                        }
                        Spacer()
                        SkeletonBlock(width: 60, height: 22, cornerRadius: 8)
                    }
                    SkeletonBlock(height: 80, cornerRadius: 10)
                }
                .padding(16)
            )
    }
}

private struct SkeletonBlock: View {
    var width: CGFloat?
    var height: CGFloat
    var cornerRadius: CGFloat = 6
    
    @ViewBuilder
    var body: some View {
        if let width {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.bgInput)
                .frame(width: width, height: height)
                .signupShimmer()
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.bgInput)
                .frame(height: height)
                .frame(maxWidth: .infinity, alignment: .leading)
                .signupShimmer()
        }
    }
}

private struct SignupShimmerModifier: ViewModifier {
    @State private var offset: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0),
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: geometry.size.width * offset)
                        .frame(width: geometry.size.width * 1.5)
                }
                .clipped()
            )
            .mask(content)
            .onAppear {
                offset = -1
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    offset = 1.2
                }
            }
    }
}

private extension View {
    func signupShimmer() -> some View {
        modifier(SignupShimmerModifier())
    }
}

#Preview {
    SignupCurationSkeletonView()
        .padding()
        .background(Color.bgSystem)
}
