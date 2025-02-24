//
//  TabSelector.swift
//  Newdok
//
//  Created by 권민재 on 2/23/25.
//
import SwiftUI

struct SlidingTabBarView: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
               
                TabButton(title: "추천 뉴스레터", isSelected: selectedTab == 0) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 0
                    }
                }

                
                TabButton(title: "모든 뉴스레터", isSelected: selectedTab == 1) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 1
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)

           
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / 2
                Rectangle()
                    .frame(width: 90, height: 2)
                    .foregroundColor(.blue)
                    .offset(x: selectedTab == 0 ? -tabWidth / 2 : tabWidth / 2)
                    .matchedGeometryEffect(id: "underline", in: animation)
            }
            .frame(height: 2)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.hanSansNeo(16, .bold))
                .foregroundColor(isSelected ? .blue : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    
    SlidingTabBarView(selectedTab: $selectedTab)
        
}
