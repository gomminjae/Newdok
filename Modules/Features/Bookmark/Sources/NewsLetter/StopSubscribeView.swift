//
//  StopSubscribeView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

public struct StopSubscribeView: View {
    
    var onClose: () -> Void
    
    public var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    onClose()
                }
            VStack(alignment: .center) {
                Image("warning")
                Text("'Freaky Whiskey Friday'")
                Text("구독 중지")
                Text("구독을 중지하면 더이상\n새로운 아티클을 수신되지 않아요.")
                
                VStack {
                    Text("구독 재개로 언제든 아니클을 다시 받아볼 수 있어요.")
                }
            }
            .background(Color.white)
        }
    }
}

#Preview {
    StopSubscribeView(onClose: {})
}
