//
//  CalendarPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//

import SwiftUI
import UIKit

struct RoundedCorners: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

public struct CalendarPopupView: View {
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    @State private var displayedMonthDate = Date()
    
    public var onDateSelected: ((Date) -> Void)?
    public var onMonthChanged: ((Date) -> Void)?
    /// 데이터가 있는 날짜를 외부에서 전달 받습니다.
    public var dataDates: Set<Date>

    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    private var today: Date {
        calendar.startOfDay(for: Date())
    }

    public init(
        isPresented: Binding<Bool>,
        dataDates: Set<Date> = [],
        onDateSelected: ((Date) -> Void)? = nil,
        onMonthChanged: ((Date) -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.dataDates = dataDates.map { Calendar.current.startOfDay(for: $0) }
            .reduce(into: []) { $0.insert($1) }
        self.onDateSelected = onDateSelected
        self.onMonthChanged = onMonthChanged
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Calendar container
            VStack(spacing: 0) {
                headerView
                weekdayHeader
                dateGrid
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    
            )
            .padding(.horizontal, 20)

            // Today button
            Button(action: selectToday) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .renderingMode(.template)
                        .foregroundStyle(Color.primaryNormal)
                    Text("오늘")
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.primaryNormal)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primaryNormal))
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Subviews
    private var headerView: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                
                Text(yearMonthTitle)
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#1E1E1E"))
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                Spacer()
                
                
            }
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                .padding(.trailing,16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color(hex: "#FAFAFA")
                .clipShape(RoundedCorners(radius: 16, corners: [.topLeft, .topRight]))
        )
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdays.enumerated()), id: \.0) { index, day in
                Text(day)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(index == 0 ? .red : (index == 6 ? .blue : .gray))
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }

    private var dateGrid: some View {
        let days = generateDays()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            
            ForEach(Array(days.enumerated()), id: \.0) { index, day in
                let isFuture = calendar.startOfDay(for: day.date) > today
                let isToday = isSameDay(day.date, today)
                let isSelected = isSameDay(day.date, selectedDate)
                let hasData = dataDates.contains(calendar.startOfDay(for: day.date))
                let isBlank = day.dayInt == 0

                VStack(spacing: 4) {
                    Text(day.dayString)
                        .frame(width: 40, height: 40)
                        .foregroundColor(
                            isFuture
                                ? Color(hex: "#C0C0C0")
                                : Color(hex: "#1E1E1E")
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.blue : .clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isToday && !isSelected ? Color.blue : .clear, lineWidth: 2)
                                )
                        )

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 5, height: 5)
                        .opacity(hasData && !isBlank ? 1 : 0)
                }
                .opacity(isBlank ? 0.3 : 1)
                .onTapGesture {
                    guard !isFuture, hasData, !isSelected else { return }
                    selectedDate = day.date
                    onDateSelected?(day.date)
                    isPresented = false
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }


    // MARK: - Helpers
    private var yearMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: displayedMonthDate)
    }

    private func generateDays() -> [CalendarDay] {
        var days = [CalendarDay]()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate))!
        let weekdayOfFirst = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: displayedMonthDate)!

        for _ in 1..<weekdayOfFirst {
            days.append(CalendarDay(date: Date.distantPast, dayString: "", dayInt: 0))
        }
        for day in range {
            let date = calendar.date(bySetting: .day, value: day, of: displayedMonthDate)!
            days.append(CalendarDay(date: date, dayString: "\(day)", dayInt: day))
        }
        while days.count % 7 != 0 {
            days.append(CalendarDay(date: Date.distantPast, dayString: "", dayInt: 0))
        }
        return days
    }

    private func previousMonth() {
        displayedMonthDate = calendar.date(byAdding: .month, value: -1, to: displayedMonthDate)!
        onMonthChanged?(displayedMonthDate)
    }

    private func nextMonth() {
        displayedMonthDate = calendar.date(byAdding: .month, value: 1, to: displayedMonthDate)!
        onMonthChanged?(displayedMonthDate)
    }

    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }

    private func textColor(
        weekdayIndex: Int,
        isFuture: Bool,
        hasData: Bool,
        isSelected: Bool
    ) -> Color {
        // 선택된 날짜면 흰색
        if isSelected {
            return .white
        }
        // 미래 날짜면 무조건 회색
        if isFuture {
            return Color(hex: "#C0C0C0")
        }
        // 그 외 주말/평일 구분
        switch weekdayIndex {
        case 0: return .red
        case 6: return .blue
        default: return .black
        }
    }

    private func selectToday() {
        selectedDate = today
        displayedMonthDate = today
        onDateSelected?(today)
        isPresented = false
    }
}

struct CalendarDay: Hashable {
    let date: Date
    let dayString: String
    let dayInt: Int
}

