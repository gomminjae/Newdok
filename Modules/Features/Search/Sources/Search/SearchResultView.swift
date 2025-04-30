//
//  SearchResultView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

public struct SearchResultView: View {
    @Environment(\.dismiss) private var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            
         
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                    .padding(.leading, 20)
                Spacer()
            }
            .frame(height: 50)
            .background(.white)
            
            Divider()
            
      
            HStack(spacing: 16) {
                Button(action: { dismiss() }) {
                    Image("back")
                        .foregroundColor(.black)
                }
                
                Text("뉴닉")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                Button(action: {
                    
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 45)
            .background(.white)
            
            Divider()
            
     
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
              
                    VStack(alignment: .leading, spacing: 12) {
                        Text("뉴스레터")
                            .font(.hanSansNeo(16,.medium))
                        
                        HStack(spacing: 12) {
                            //NewsLetterEmptyView()
                            Image("banner")
                                .resizable()
                                .frame(width: 58, height: 58)
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("NEWNEEK")
                                    .font(.hanSansNeo(16,.medium))
                                Text("세상 돌아가는 소식, 뉴닉으로!")
                                    .font(.hanSansNeo(14,.regular))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 2)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("아티클 (52)")
                            .font(.hanSansNeo(16,.medium))
                        
                        ForEach(0..<3) { _ in
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🦔 정부24 먹통 사건의 전말.txt")
                                    .font(.hanSansNeo(16,.medium))
                                    .lineLimit(1)
                                
                                Text("오늘의 뉴닉 지난 주말 일어난 행정복지센터·정부24 서비스 먹통 사태, 대체 무슨 일인지 살펴봤고 재건축 규제완화 등 주요 이슈를 정리해봤어요.")
                                    .font(.hanSansNeo(14,.regular))
                                    .foregroundColor(.gray)
                                    
                                    .lineLimit(2)
                                
                                HStack {
                                    Image("signup")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .background(.red)
                                        .clipShape(Circle())
                                    
                                    Text("주간 컴퍼니타임스")
                                        .font(.hanSansNeo(14,.medium))
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Text("2023-11-26")
                                        .font(.hanSansNeo(12,.regular))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 2)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 10)
            }
            .background(Color.gray.opacity(0.05))
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .background(Color.gray.opacity(0.05).ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        SearchResultView()
    }
}
