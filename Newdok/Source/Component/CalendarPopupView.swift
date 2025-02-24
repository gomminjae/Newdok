//
//  CalendarPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

struct PopupViewModifier<Popup: View>: ViewModifier {
    @Binding var isPresented: Bool
    let popupContent: Popup
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(.easeInOut, value: isPresented)
                    .onTapGesture {
                        isPresented = false // 바깥을 터치하면 닫힘
                    }
                
                popupContent
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(), value: isPresented)
            }
        }
    }
}

extension View {
    func popup<Popup: View>(
        isPresented: Binding<Bool>,
        popupContent: @escaping () -> Popup
    ) -> some View {
        modifier(PopupViewModifier(isPresented: isPresented, popupContent: popupContent()))
    }
}
import SwiftUI

struct CalendarPopupView: View {
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    
    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    // 점이 표시될 날짜 목록 (임시로 설정)
    private let datesWithEvents: [Int] = [1,3,4,9,11,12,13,14,15,16,18,19,20,21,23,25,26,27,28,29,30]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Button(action: { previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color(hex: "#333333"))
                        .padding(.bottom,20)
                }
                Text(yearMonthTitle)
                    .font(.headline)
                    .frame(width: 120, height: 20)
                    .foregroundStyle(Color(hex: "#1E1E1E"))
                    .padding(.bottom,20)
                Button(action: { nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "#333333"))
                        .padding(.bottom,20)
                }
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color(hex: "#1E1E1E"))
                        .padding(.bottom,20)
                }
            }
            .background(Color(hex: "#FAFAFA"))
            .padding(.top, 20)
            
            // 요일 표시
            HStack {
                ForEach(weekdays.indices, id: \.self) { idx in
                    Text(weekdays[idx])
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(idx == 0 ? .red : (idx == 6 ? .blue : .gray))
                }
            }
            .background(.white)
            
            // 날짜 표시 영역
            let daysInMonth = generateDays()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth, id: \.self) { day in
                    VStack(spacing: 4) {
                        Text(day.dayString)
                            .foregroundColor(textColor(for: day.date))
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSameDay(day.date, selectedDate) ? Color.blue : Color.clear)
                            )
                        
                        Circle()
                            .fill(Color.primaryNormal)
                            .frame(width: 5, height: 5)
                            .opacity(datesWithEvents.contains(day.dayInt) ? 1 : 0)
                    }
                    .onTapGesture {
                        selectedDate = day.date
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white).shadow(radius: 5))
        .padding(.horizontal, 20)
    }
    

    var yearMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: selectedDate)
    }
    

    func generateDays() -> [CalendarDay] {
        var days = [CalendarDay]()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let startDay = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        
 
        for _ in 1..<startDay {
            days.append(CalendarDay(date: Date.distantPast, dayString: "", dayInt: 0))
        }
        
      
        for day in range {
            let date = calendar.date(bySetting: .day, value: day, of: selectedDate)!
            days.append(CalendarDay(date: date, dayString: "\(day)", dayInt: day))
        }
        
        return days
    }
    
 
    func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }
    func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func textColor(for date: Date) -> Color {
        if date == Date.distantPast {
            return .clear
        }
        if isSameDay(date, selectedDate) {
            return .white
        }
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 ? .red : (weekday == 7 ? .blue : .primary)
    }
}

// 날짜 정보를 담을 구조체
struct CalendarDay: Hashable {
    let date: Date
    let dayString: String
    let dayInt: Int
}

// ✅ 프리뷰 컨테이너 추가
struct CalendarPopupView_Previews_Container: View {
    @State private var isPresented = true
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            
            CalendarPopupView(isPresented: $isPresented)
        }
    }
}

#Preview {
    CalendarPopupView_Previews_Container()
}
