//
//  SubscribeView.swift
//  Newdok
//
//  Created by 권민재 on 3/3/25.
//

import SwiftUI

struct SubscribeView: View {
    @State private var selectedTab: Int = 0 // 0: 구독 중, 1: 구독 중지
    
    let subscriptions = [
        ("Alone&around", "평일 아침", "alone"),
        ("Daily Byte", "평일 오전 6시", "daily"),
        ("NEWNEEK", "매주 평일 아침", "newneek"),
        ("다다레터", "격주 목요일 아침", "dada"),
        ("머니레터", "평일 오전 6시", "money")
    ]
    
    var body: some View {
        VStack {
            // 상단 헤더
            headerView()
            
            // Segmented Picker
            Picker(selection: $selectedTab, label: Text("구독 상태")) {
                Text("구독 중").tag(0)
                Text("구독 중지").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 구독 리스트
            List {
                listHeaderView()
                ForEach(filteredSubscriptions, id: \.0) { name, time, imageName in
                    HStack {
                        Image(imageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.headline)
                            Text(time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button(action: {
                            print("\(name) 구독 취소 버튼 탭")
                        }) {
                            Text("구독중지")
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .background(Color(hex: "#F5F5F7"))
            .listStyle(PlainListStyle())
            .padding(.top,16)
        }
    }
    
    @ViewBuilder
    private func listHeaderView() -> some View {
        VStack(alignment: .leading) {
            Text("총 8개의 뉴스레터 구독중이에요.")
                
                .font(.hanSansNeo(16, .bold))
                .padding(.top,32)
            Text("구독신청 후 첫 아티클을 수신받으면 내 구독에 추가돼요.")
                .font(.hanSansNeo(14, .medium))
                .foregroundStyle(Color(hex: "#565656"))
                .padding(.top, 8)
        }
        .background(.clear)
    }
    
    
    // 헤더 뷰
    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            Text("내 구독")
                .font(.system(size: 18, weight: .bold))
                .padding(.vertical, 17)
                .padding(.leading, 20)
            
            Spacer()
            
            Button(action: {
                print("검색 버튼 탭")
            }) {
                Image("search")
                    .padding(.vertical, 17)
                    .padding(.trailing, 2.4)
            }
            
            Button(action: {
                print("알람 버튼 탭")
            }) {
                Image("bell")
                    .padding(.vertical, 17)
                    .padding(.leading, 16)
                    .padding(.trailing, 17.8)
            }
        }
    }
    
    // 현재 선택된 탭에 따라 필터링된 구독 리스트 반환
    private var filteredSubscriptions: [(String, String, String)] {
        if selectedTab == 0 {
            return subscriptions // "구독 중" 리스트
        } else {
            return [] // "구독 중지" 리스트 (데이터가 없는 상태)
        }
    }
}

#Preview {
    SubscribeView()
}
