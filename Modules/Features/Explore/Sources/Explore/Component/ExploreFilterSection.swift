import SwiftUI
import DesignSystem
import Shared

struct ExploreFilterSection: View {
    @Binding var orderOpt: String?
    @Binding var industry: [SelectableItem]?
    @Binding var day: [SelectableItem]?
    @Binding var isShowSortSheet: Bool
    @Binding var isShowFilterSheet: Bool

    let industryText: String
    let dayText: String
    let industries: [SelectableItem]
    let days: [SelectableItem]
    let onSort: () async -> Void
    let onFilter: () async -> Void
    let onReset: () async -> Void

    @State private var filterSpinAngle: Double = 0

    var body: some View {
        HStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    sortButton
                    Rectangle()
                        .frame(width: 1, height: 20)
                        .foregroundColor(Color.lineNeutral)
                    industryFilterButton
                    dayFilterButton
                }
            }
            .frame(maxWidth: .infinity)

            refreshButton
        }
        .sheet(isPresented: $isShowSortSheet) {
            SortBottomSheet(orderOpt: $orderOpt) {
                await onSort()
            }
            .background(Color.white)
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isShowFilterSheet) {
            FilterBottomSheet(industries: industries, weekdays: days, industry: $industry, day: $day) {
                await onFilter()
            }
        }
    }

    private var sortButton: some View {
        Button(action: { isShowSortSheet.toggle() }) {
            HStack(spacing: 4) {
                Text(orderOpt ?? "인기순")
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(Color.captionStrong)
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.captionStrong)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.lineNeutral, lineWidth: 1))
        }
        .accessibilityLabel("정렬: \(orderOpt ?? "인기순")")
        .accessibilityIdentifier("explore_sort_button")
        .buttonStyle(PlainButtonStyle())
    }

    private var industryFilterButton: some View {
        Button(action: { isShowFilterSheet.toggle() }) {
            HStack(spacing: 4) {
                Text(industryText)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(industry != nil ? Color.primaryNormal : Color.captionAssistive)
                Image(asset: DesignSystemAsset.lineDown)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(industry != nil ? Color.primaryNormal : Color.captionAssistive)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(industry != nil ? Color.primaryNormal : Color.lineNeutral, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var dayFilterButton: some View {
        Button(action: { isShowFilterSheet.toggle() }) {
            HStack(spacing: 4) {
                Text(dayText)
                    .font(.hanSansNeo(14, .medium))
                    .foregroundStyle(day != nil ? Color.primaryNormal : Color.captionAssistive)
                Image(asset: DesignSystemAsset.lineDown)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(day != nil ? Color.primaryNormal : Color.captionAssistive)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(day != nil ? Color.primaryNormal : Color.lineNeutral, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var refreshButton: some View {
        Button(action: {
            filterSpinAngle += 360
            Task { await onReset() }
        }) {
            Image(asset: DesignSystemAsset.lineReload)
                .renderingMode(.template)
                .frame(width: 30, height: 30)
                .foregroundColor(Color.primaryNormal)
                .rotationEffect(.degrees(filterSpinAngle))
                .animation(.linear(duration: 0.8), value: filterSpinAngle)
        }
    }
}
