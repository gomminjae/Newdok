//
//  SelectableItemStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//

import Foundation
import Observation

@Observable
@MainActor
public final class SelectableItemStore: SelectableItemStoreProtocol {
    public private(set) var loadState: SelectableOptionsLoadState = .idle
    private var options: SelectableOptions?

    public var interests: [SelectableItem] { options?.interests ?? [] }
    public var industries: [SelectableItem] { options?.industries ?? [] }
    public var days: [SelectableItem] { options?.days ?? [] }

    private let fetchOptionsUseCase: any FetchSelectableOptionsUseCase

    public init(fetchOptionsUseCase: any FetchSelectableOptionsUseCase) {
        self.fetchOptionsUseCase = fetchOptionsUseCase
    }

    public func loadIfNeeded() async throws {
        try Task.checkCancellation()
        guard loadState != .loaded else { return }
        loadState = .loading
        do {
            let options = try await fetchOptionsUseCase.execute()
            try Task.checkCancellation()
            try Self.validate(options)
            self.options = options
            loadState = .loaded
        } catch {
            // A different screen may have already loaded the same reference data.
            if loadState != .loaded {
                loadState = Task.isCancelled || error is CancellationError ? .idle : .failed
            }
            throw error
        }
    }

    private static func validate(_ options: SelectableOptions) throws {
        for items in [options.interests, options.industries, options.days] {
            guard Set(items.map(\.id)).count == items.count,
                  items.allSatisfy({ !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
                throw AppError.userMessage("선택 목록을 확인할 수 없습니다. 다시 시도해주세요.")
            }
        }
    }

    public func list(for category: SelectableCategoryType) -> [SelectableItem] {
        switch category {
        case .interest: return interests
        case .industry: return industries
        case .day: return days
        }
    }

    public func name(for id: Int, in category: SelectableCategoryType) -> String {
        list(for: category).first(where: { $0.id == id })?.name ?? ""
    }

    public func id(for name: String, in category: SelectableCategoryType) -> Int? {
        list(for: category).first(where: { $0.name == name })?.id
    }
}
