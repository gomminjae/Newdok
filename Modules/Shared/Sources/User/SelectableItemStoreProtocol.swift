//
//  SelectableItemStoreProtocol.swift
//  Shared
//
//  Created by Claude on 5/9/26.
//

import Foundation

public protocol SelectableItemStoreProtocol {
    var interests: [SelectableItem] { get }
    var industries: [SelectableItem] { get }
    var days: [SelectableItem] { get }

    func loadOptions(interests: [SelectableItem], industries: [SelectableItem], days: [SelectableItem])
    func list(for category: SelectableCategoryType) -> [SelectableItem]
    func name(for id: Int, in category: SelectableCategoryType) -> String
    func id(for name: String, in category: SelectableCategoryType) -> Int?
}
