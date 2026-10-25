//
//  SelectableItemStoreProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

@MainActor
public protocol SelectableItemStoreProtocol: Sendable {
    var loadState: SelectableOptionsLoadState { get }
    var interests: [SelectableItem] { get }
    var industries: [SelectableItem] { get }
    var days: [SelectableItem] { get }

    func loadIfNeeded() async throws
    func list(for category: SelectableCategoryType) -> [SelectableItem]
    func name(for id: Int, in category: SelectableCategoryType) -> String
    func id(for name: String, in category: SelectableCategoryType) -> Int?
}
