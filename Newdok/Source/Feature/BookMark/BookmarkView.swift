//
//  BookMark.swift
//  Newdok
//
//  Created by 권민재 on 2/28/25.
//

import SwiftUI

struct BookmarkView: View {
    var body: some View {
        VStack {
            HStack {
                Text("북마크함")
                    .font(.hanSansNeo(16, .bold))
                Spacer()
                Button(action: {
                    
                }) {
                    Image("search")
                }
                Button(action: {
                    
                }) {
                    Image("bell")
                }
            }
            HStack {
                
            }
            
            HStack {
                
            }
            VStack {
                
            }
        }
    }
}

#Preview {
    BookmarkView()
}
