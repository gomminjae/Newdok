//
//  CalendarPopupView.swift
//  Newdok
//
//  Created by 권민재 on 2/24/25.
//
import SwiftUI
import UIKit

// MARK: - CalendarPopupView
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
    @State private var forceUpdate: Bool = false

    public var onDateSelected: ((Date) -> Void)?
    public var onMonthChanged: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    private let weekdays = ["일","월","화","수","목","금","토"]
    private var today: Date { calendar.startOfDay(for: Date()) }

    public init(
        isPresented: Binding<Bool>,
        selectedDate: Binding<Date>,
        displayedMonthDate: Binding<Date>,
        dataDays: Binding<Set<Int>>,
        isLoading: Binding<Bool> = .constant(false),
        onDateSelected: ((Date) -> Void)? = nil,
        onMonthChanged: ((Date) -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self._selectedDate = selectedDate
        self._displayedMonthDate = displayedMonthDate
        self._dataDays = dataDays
        self._isLoading = isLoading
        self.onDateSelected = onDateSelected
        self.onMonthChanged = onMonthChanged
    }

    public var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                headerView
                weekdayHeader
                dateGrid
            }
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .padding(.horizontal, 20)

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
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.primaryNormal))
            }
            .padding(.top, 20)
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .onChange(of: displayedMonthDate) { _ in forceUpdate.toggle() }
        .onChange(of: dataDays) { _ in forceUpdate.toggle() }
        .onChange(of: selectedDate) { _ in forceUpdate.toggle() } // React to selection change
    }

    private var headerView: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color(hex: "#333333"))
                }
                Text(yearMonthTitle)
                    .frame(width: 120, height: 20)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color(hex: "#1E1E1E"))
                    .id("month-title-\(displayedMonthDate)-\(forceUpdate)-\(selectedDate)")
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
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .background(
            Color(hex: "#FAFAFA")
                .clipShape(RoundedCorners(radius: 16, corners: [.topLeft, .topRight]))
        )
    }

    private var weekdayHeader: some View {
        HStack(spacing: 10) {
            ForEach(Array(weekdays.enumerated()), id: \.0) { idx, day in
                Text(day)
                    .font(.hanSansNeo(16, .regular))
                    .frame(width: 40, height: 40)
                    .foregroundColor(idx == 0 ? .red : (idx == 6 ? .blue : .black))
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
    }

    private var dateGrid: some View {
        let days = generateDays()
        return VStack(spacing: 10) {
            ForEach(0..<(days.count / 7), id: \.self) { weekIndex in
                HStack(spacing: 10) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let day = days[weekIndex * 7 + dayIndex]
                        let isFuture = calendar.startOfDay(for: day.date) > today
                        let isToday = calendar.isDate(day.date, inSameDayAs: today)
                        let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
                        let hasData = dataDays.contains(day.dayInt)
                        let isBlank = day.dayInt == 0

                        VStack(spacing: 4) {
                            Text(day.dayString)
                                .font(.hanSansNeo(16, .regular))
                                .frame(width: 40, height: 40)
                                .foregroundColor(
                                    isFuture ? Color(hex: "#C0C0C0") :
                                    (isSelected ? .white :
                                     (isToday ? .white : Color(hex: "#171414")))
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            isSelected ? Color.blue :
                                            (isToday ? Color.primaryNormal : .clear)
                                        )
                                )
                            Circle()
                                .frame(width: 5, height: 5)
                                .foregroundColor(Color.blue)
                                .opacity(hasData && !isBlank ? 1 : 0)
                        }
                        .opacity(isBlank ? 0.3 : 1)
                        .onTapGesture {
                            guard !isBlank else { return }
                            selectedDate = day.date
                            onDateSelected?(day.date)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .id("calendar-grid-\(displayedMonthDate)-\(forceUpdate)-\(selectedDate)")
    }

    private var yearMonthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: displayedMonthDate)
    }

    private func generateDays() -> [CalendarDay] {
        var days = [CalendarDay]()
        let startOfMonth = calendar.date(from:
            calendar.dateComponents([.year, .month], from: displayedMonthDate))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let range = calendar.range(of: .day, in: .month, for: displayedMonthDate)!

        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: .distantPast, dayString: "", dayInt: 0))
        }
        for d in range {
            let date = calendar.date(bySetting: .day, value: d, of: displayedMonthDate)!
            days.append(CalendarDay(date: date, dayString: "\(d)", dayInt: d))
        }
        while days.count % 7 != 0 {
            days.append(CalendarDay(date: .distantPast, dayString: "", dayInt: 0))
        }
        return days
    }

    private func previousMonth() {
        let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonthDate)!
        displayedMonthDate = newDate
        forceUpdate.toggle()
        DispatchQueue.main.async { forceUpdate.toggle() }
        onMonthChanged?(displayedMonthDate)
    }
    
    private func nextMonth() {
        let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonthDate)!
        displayedMonthDate = newDate
        forceUpdate.toggle()
        DispatchQueue.main.async { forceUpdate.toggle() }
        onMonthChanged?(displayedMonthDate)
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

struct CalendarPopupView_Previews: PreviewProvider {
    static var previews: some View {
        let today = Date()
        let firstOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: today))!
        return CalendarPopupView(
            isPresented: .constant(true),
            selectedDate: .constant(today),
            displayedMonthDate: .constant(firstOfMonth),
            dataDays: .constant([1,5,10,15])
        )
        .padding(.horizontal, 20)
        .previewLayout(.sizeThatFits)
        .background(Color.gray.opacity(0.2))
    }
}
