//
//  SegmentPickerView.swift
//  Newdok
//
//  Created by 권민재 on 3/3/25.
//

import SwiftUI

struct SegmentPickerView: View {
  @State var selectedTab = "구독 중"
  var colors = ["구독 중","구독 중지"]
  
    var body: some View {
        
        VStack {
            Picker("", selection: $selectedTab) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .background(.white)
            .cornerRadius(6)
        
            
        }
    }
}

#Preview {
    SegmentPickerView()
}
