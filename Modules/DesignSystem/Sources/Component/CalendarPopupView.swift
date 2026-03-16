//
//  CalendarPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//
import SwiftUI
import UIKit
import Combine

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
    @Binding var selectedDate: Date
    @Binding var displayedMonthDate: Date
    @Binding var isLoading: Bool
    @Binding var dataDays: Set<Int>
    @State private var localSelectedDate: Date
    @State private var localDisplayedMonthDate: Date

    public var onDateSelected: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    private var today: Date { calendar.startOfDay(for: Date()) }

    public init(
        isPresented: Binding<Bool>,
        selectedDate: Binding<Date>,
        displayedMonthDate: Binding<Date>,
        dataDays: Binding<Set<Int>>,
        isLoading: Binding<Bool> = .constant(false),
        onDateSelected: ((Date) -> Void)? = nil,
    ) {
        self._isPresented = isPresented
        self._selectedDate = selectedDate
        self._displayedMonthDate = displayedMonthDate
        self._dataDays = dataDays
        self._isLoading = isLoading
        self._localSelectedDate = State(initialValue: selectedDate.wrappedValue)
        self._localDisplayedMonthDate = State(initialValue: displayedMonthDate.wrappedValue)
        self.onDateSelected = onDateSelected
    }

    public var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                headerView
                weekdayHeader
                dateGrid
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            
            // 오늘 버튼
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
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primaryNormal, lineWidth: 1))
            }
            .padding(.top, 20)
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .onChange(of: displayedMonthDate) { _, newValue in
            localDisplayedMonthDate = newValue
        }
        .onChange(of: dataDays) { _ in }
        .onChange(of: selectedDate) { _, newValue in
            localSelectedDate = newValue
        }
        .onAppear {
            // 초기 설정만 수행
        }
    }

    private var headerView: some View {
        GeometryReader { _ in
            ZStack {
                HStack {
                    Spacer()
                    Button(action: {
                        previousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.captionTitle)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text(yearMonthTitle)
                        .frame(width: 120, height: 20)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionDeep)
                        .id("month-title-\(localDisplayedMonthDate)")
                    
                    Button(action: {
                        nextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.captionTitle)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(asset: DesignSystemAsset.lineClose)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 18)
            }
        }
        .frame(height: 44)
        .background(
            Color.bgElevated
                .clipShape(RoundedCorners(radius: 16, corners: [.topLeft, .topRight]))
        )
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdays.enumerated()), id: \.0) { idx, day in
                Text(day)
                    .font(.hanSansNeo(16, .regular))
                    .frame(maxWidth: .infinity)
                    .frame(height: 20)
                    .foregroundColor(idx == 0 ? .red : (idx == 6 ? .blue : .black))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(Color.white)
    }

    private var dateGrid: some View {
        let days = generateDays()
        return VStack(spacing: 10) {
            ForEach(0..<(days.count / 7), id: \.self) { weekIndex in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let day = days[weekIndex * 7 + dayIndex]
                        let isFuture = calendar.startOfDay(for: day.date) > today
                        let isToday = calendar.isDate(day.date, inSameDayAs: today)
                        let isSelected = calendar.isDate(day.date, inSameDayAs: localSelectedDate)
                        let hasData = dataDays.contains(day.dayInt)
                        let isBlank = day.dayInt == 0
                        
                        VStack(spacing: 4) {
                            Text(day.dayString)
                                .font(.hanSansNeo(16, .regular))
                                .frame(maxWidth: .infinity, maxHeight: 40)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundColor(
                                    isFuture ? Color.captionDisabled :
                                    (isToday ? .white :
                                     (isSelected ? Color.captionMuted : Color.captionMuted))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            isToday ? Color.primaryNormal : .clear
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isSelected && !isToday ? Color.primaryDark : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                            
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(Color.blue)
                                .opacity(hasData && !isBlank ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                       
                        .opacity(isBlank ? 0.3 : 1)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard !isBlank else { return }
                            localSelectedDate = day.date
                            selectedDate = day.date
                            onDateSelected?(day.date)
                            isPresented = false
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .id("calendar-grid-\(localDisplayedMonthDate.timeIntervalSince1970)-\(dataDays.hashValue)")
    }

    private var yearMonthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: localDisplayedMonthDate)
    }

    private func generateDays() -> [CalendarDay] {
        var days = [CalendarDay]()
        let startOfMonth = calendar.date(from:
            calendar.dateComponents([.year, .month], from: localDisplayedMonthDate))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: localDisplayedMonthDate)!

        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: .distantPast, dayString: "", dayInt: 0))
        }
        for d in range {
            let date = calendar.date(bySetting: .day, value: d, of: localDisplayedMonthDate)!
            days.append(CalendarDay(date: date, dayString: "\(d)", dayInt: d))
        }
        while days.count % 7 != 0 {
            days.append(CalendarDay(date: .distantPast, dayString: "", dayInt: 0))
        }
        return days
    }

    private func previousMonth() {
        let newDate = calendar.date(byAdding: .month, value: -1, to: localDisplayedMonthDate)!
        localDisplayedMonthDate = newDate
        displayedMonthDate = newDate
    }
    
    private func nextMonth() {
        let newDate = calendar.date(byAdding: .month, value: 1, to: localDisplayedMonthDate)!
        localDisplayedMonthDate = newDate
        displayedMonthDate = newDate
    }
    
    private func selectToday() {
        selectedDate = today
        onDateSelected?(today)
        isPresented = false
    }
}

struct CalendarDay: Hashable {
    let date: Date
    let dayString: String
    let dayInt: Int
}
