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
    @State private var displayedMonthDate = Date()

    public var onDateSelected: ((Date) -> Void)?

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private let newsletterDays: Set<Int> = [1, 3, 4, 9, 11, 12, 13, 14, 15, 16, 18, 19, 20, 21, 23, 25, 26, 27, 28, 29, 30]
    private var today: Date {
        calendar.startOfDay(for: Date())
    }

    public init(isPresented: Binding<Bool>, onDateSelected: ((Date) -> Void)? = nil) {
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
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .background(.white)

            // 날짜 그리드
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(generateDays(), id: \.self) { day in
                    let isFuture = calendar.startOfDay(for: day.date) > today
                    let isToday = isSameDay(day.date, today)
                    let isSelected = isSameDay(day.date, selectedDate)
                    let isSelectable = !isFuture && newsletterDays.contains(day.dayInt)

                    VStack(spacing: 4) {
                        Text(day.dayString)
                            .foregroundColor(textColor(for: day.date, isSelectable: isSelectable, isFuture: isFuture, isSelected: isSelected))
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? Color.blue : .clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                isToday && !isSelected ? Color.blue : .clear,
                                                lineWidth: 2
                                            )
                                    )
                            )

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 5, height: 5)
                            .opacity(newsletterDays.contains(day.dayInt) ? 1 : 0)
                    }
                    .onTapGesture {
                        if isFuture || !isSelectable || isSelected {
                            return
                        }
                        selectedDate = day.date
                        onDateSelected?(day.date)
                        isPresented = false
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)

            // 오늘 버튼
            if !isSameDay(selectedDate, today) &&
                calendar.isDate(today, equalTo: displayedMonthDate, toGranularity: .month) {
                Button(action: {
                    selectedDate = today
                    onDateSelected?(today)
                    isPresented = false
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("오늘")
                    }
                    .font(.subheadline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            }
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
        return formatter.string(from: displayedMonthDate)
    }

    private func generateDays() -> [CalendarDay] {
        var days = [CalendarDay]()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate))!
        let startDay = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: displayedMonthDate)!

        for _ in 1..<startDay {
            days.append(CalendarDay(date: Date.distantPast, dayString: "", dayInt: 0))
        }

        for day in range {
            let date = calendar.date(bySetting: .day, value: day, of: displayedMonthDate)!
            days.append(CalendarDay(date: date, dayString: "\(day)", dayInt: day))
        }

        return days
    }

    private func previousMonth() {
        displayedMonthDate = calendar.date(byAdding: .month, value: -1, to: displayedMonthDate)!
    }

    private func nextMonth() {
        displayedMonthDate = calendar.date(byAdding: .month, value: 1, to: displayedMonthDate)!
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    private func textColor(for date: Date, isSelectable: Bool, isFuture: Bool, isSelected: Bool) -> Color {
        if date == Date.distantPast {
            return .clear
        }
        if isSelected {
            return .white
        }
        if isFuture || !isSelectable {
            return Color.gray.opacity(0.3)
        }
        return .black
    }
}

struct CalendarDay: Hashable {
    let date: Date
    let dayString: String
    let dayInt: Int
}
