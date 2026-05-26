import SwiftUI
import Shared
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

public enum CalendarCell: Hashable {
    case blank
    case day(date: Date, value: Int)

    var date: Date {
        if case let .day(d, _) = self { return d }
        return .distantPast
    }

    var value: Int {
        if case let .day(_, v) = self { return v }
        return 0
    }

    var label: String {
        value == 0 ? "" : "\(value)"
    }

    var isBlank: Bool {
        if case .blank = self { return true }
        return false
    }
}

public struct CalendarPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    @Binding var displayedMonthDate: Date
    @Binding var isLoading: Bool
    @Binding var dataDays: Set<Int>

    public var onDateSelected: ((Date) -> Void)?

    @State private var cells: [CalendarCell] = []

    private let calendar = Calendar.current
    private var weekdaySymbols: [String] {
        var symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstIndex = calendar.firstWeekday - 1
        if firstIndex > 0 {
            symbols = Array(symbols[firstIndex...]) + Array(symbols[..<firstIndex])
        }
        return symbols
    }
    private var today: Date { calendar.startOfDay(for: Date()) }

    public init(
        isPresented: Binding<Bool>,
        selectedDate: Binding<Date>,
        displayedMonthDate: Binding<Date>,
        dataDays: Binding<Set<Int>>,
        isLoading: Binding<Bool> = .constant(false),
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self._selectedDate = selectedDate
        self._displayedMonthDate = displayedMonthDate
        self._dataDays = dataDays
        self._isLoading = isLoading
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
            .accessibilityLabel("오늘 날짜로 이동")
            .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.todayButton)
            .padding(.top, 20)
        }
        .background(Color.clear)
        .contentShape(Rectangle())
        .onAppear { regenerateCells() }
        .onChange(of: displayedMonthDate) { _, _ in regenerateCells() }
    }

    private var headerView: some View {
        GeometryReader { _ in
            ZStack {
                HStack {
                    Spacer()
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.captionTitle)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("이전 달")
                    .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.previousMonth)

                    Text(yearMonthTitle)
                        .frame(width: 120, height: 20)
                        .font(.hanSansNeo(14, .medium))
                        .foregroundStyle(Color.captionDeep)
                        .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.monthTitle)

                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.captionTitle)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("다음 달")
                    .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.nextMonth)

                    Spacer()
                }

                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(asset: DesignSystemAsset.lineClose)
                    }
                    .accessibilityLabel("닫기")
                    .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.closeButton)
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
            ForEach(Array(weekdaySymbols.enumerated()), id: \.0) { idx, day in
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
        VStack(spacing: 10) {
            ForEach(0..<weekCount, id: \.self) { weekIndex in
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        cellView(for: cells[weekIndex * 7 + dayIndex])
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func cellView(for cell: CalendarCell) -> some View {
        let isFuture = calendar.startOfDay(for: cell.date) > today
        let isToday = calendar.isDate(cell.date, inSameDayAs: today)
        let isSelected = !cell.isBlank && calendar.isDate(cell.date, inSameDayAs: selectedDate)
        let hasData = dataDays.contains(cell.value)

        VStack(spacing: 4) {
            Text(cell.label)
                .font(.hanSansNeo(16, .regular))
                .frame(maxWidth: .infinity, maxHeight: 40)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(
                    isFuture ? Color.captionDisabled :
                        (isSelected ? .white : Color.captionMuted)
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.captionHeavy : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isToday && !isSelected ? Color.captionHeavy : Color.clear,
                            lineWidth: 1
                        )
                )

            Circle()
                .frame(width: 6, height: 6)
                .foregroundColor(Color.captionStrong)
                .opacity(hasData && !cell.isBlank ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .opacity(cell.isBlank ? 0.3 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(cell.isBlank ? "" : "\(cell.value)일\(isSelected ? ", 선택됨" : "")\(isToday ? ", 오늘" : "")\(hasData ? ", 아티클 있음" : "")")
        .accessibilityIdentifier(AccessibilityID.DesignSystem.Calendar.day(cell.value))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityAddTraits(isFuture ? .isStaticText : .isButton)
        .onTapGesture {
            guard !cell.isBlank else { return }
            selectedDate = cell.date
            onDateSelected?(cell.date)
            isPresented = false
        }
    }

    private var weekCount: Int {
        cells.count / 7
    }

    private var yearMonthTitle: String {
        displayedMonthDate.formatted(
            .dateTime.year().month(.defaultDigits).locale(Locale(identifier: "ko_KR"))
        )
    }

    private func regenerateCells() {
        cells = Self.makeCells(for: displayedMonthDate, calendar: calendar)
    }

    private static func makeCells(for monthDate: Date, calendar: Calendar) -> [CalendarCell] {
        guard
            let startOfMonth = calendar.date(
                from: calendar.dateComponents([.year, .month], from: monthDate)
            ),
            let range = calendar.range(of: .day, in: .month, for: monthDate)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leading = Array(repeating: CalendarCell.blank, count: firstWeekday - 1)
        let days = range.compactMap { day -> CalendarCell? in
            calendar.date(bySetting: .day, value: day, of: monthDate)
                .map { CalendarCell.day(date: $0, value: day) }
        }
        let total = leading.count + days.count
        let trailingCount = (7 - total % 7) % 7
        let trailing = Array(repeating: CalendarCell.blank, count: trailingCount)
        return leading + days + trailing
    }

    private func previousMonth() {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: displayedMonthDate) else { return }
        displayedMonthDate = prev
    }

    private func nextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: displayedMonthDate) else { return }
        displayedMonthDate = next
    }

    private func selectToday() {
        selectedDate = today
        onDateSelected?(today)
        isPresented = false
    }
}
