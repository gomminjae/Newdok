//
//  LoadOptionsUseCase.swift
//  Domain
//
//  Created by 권민재 on 2/3/26.
//

import Foundation
import Shared

/// 앱 시작 시 옵션 데이터를 로드하고 저장하는 UseCase
public protocol LoadOptionsUseCase {
    func execute() async throws
}

public final class LoadOptionsUseCaseImpl: LoadOptionsUseCase {

    private let newsletterUseCase: NewsletterUseCase

    public init(newsletterUseCase: NewsletterUseCase) {
        self.newsletterUseCase = newsletterUseCase
    }

    public func execute() async throws {
        let optionList = try await newsletterUseCase.fetchOptionList()

        let interests = optionList.interests.map { SelectableItem(id: $0.id, name: $0.name) }
        let industries = optionList.industries.map { SelectableItem(id: $0.id, name: $0.name) }
        let days = optionList.days.map { SelectableItem(id: $0.id, name: $0.name) }

        await MainActor.run {
            SelectableItemStore.shared.loadOptions(
                interests: interests,
                industries: industries,
                days: days
            )
        }
    }
}
