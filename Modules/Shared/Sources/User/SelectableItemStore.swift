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
public final class SelectableItemStore {
    public static let shared = SelectableItemStore()

    public private(set) var interests: [SelectableItem] = []
    public private(set) var industries: [SelectableItem] = []
    public private(set) var days: [SelectableItem] = []

    private var isLoaded = false

    private init() {}

    public func loadOptions(
        interests: [SelectableItem],
        industries: [SelectableItem],
        days: [SelectableItem]
    ) {
        self.interests = interests
        self.industries = industries
        self.days = days
        isLoaded = true
    }

    public func list(for category: SelectableCategoryType) -> [SelectableItem] {
        switch category {
        case .interest: return interests
        case .industry: return industries
        }
    }

    public func name(for id: Int, in category: SelectableCategoryType) -> String {
        list(for: category).first(where: { $0.id == id })?.name ?? ""
    }

    public func id(for name: String, in category: SelectableCategoryType) -> Int? {
        list(for: category).first(where: { $0.name == name })?.id
    }
}
