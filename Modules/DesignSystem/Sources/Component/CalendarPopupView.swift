//
//  CalendarPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI

public struct CalendarPopupView: View {
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    
    public var onDateSelected: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    
    private let datesWithEvents: [Int] = [1,3,4,9,11,12,13,14,15,16,18,19,20,21,23,25,26,27,28,29,30]
    
    public init(
        isPresented: Binding<Bool>,
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.onDateSelected = onDateSelected
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            HStack {
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                Text(yearMonthTitle)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#1E1E1E"))
                    .frame(width: 120)
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color(hex: "#1E1E1E"))
                }
            }
            .padding()
            .background(Color(hex: "#FAFAFA"))

            // 요일 헤더
            HStack {
                ForEach(weekdays.indices, id: \.self) { idx in
                    Text(weekdays[idx])
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(idx == 0 ? .red : (idx == 6 ? .blue : .gray))
                }
            }
            .padding(.horizontal, 16)
            .background(.white)

            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(generateDays(), id: \.self) { day in
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
                        onDateSelected?(day.date)
                        isPresented = false
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 8)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
    
    private var yearMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: selectedDate)
    }

    private func generateDays() -> [CalendarDay] {
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

    private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
    }

    private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    private func textColor(for date: Date) -> Color {
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


struct CalendarDay: Hashable {
    let date: Date
    let dayString: String
    let dayInt: Int
}

