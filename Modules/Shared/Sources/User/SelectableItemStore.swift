//
//  SelectableItemStore.swift
//  Shared
//
//  Created by 권민재 on 5/9/25.
//


import Foundation

public final class SelectableItemStore {
    public static let shared = SelectableItemStore()

    public let interests: [SelectableItem] = [
        .init(id: 1, name: "경제・시사・상식"),
        .init(id: 2, name: "비즈니스"),
        .init(id: 3, name: "과학・기술"),
        .init(id: 4, name: "트렌드"),
        .init(id: 5, name: "재테크"),
        .init(id: 6, name: "콘텐츠"),
        .init(id: 7, name: "라이프스타일"),
        .init(id: 8, name: "취미・자기계발"),
        .init(id: 9, name: "건강・의학"),
        .init(id: 10, name: "멘탈케어"),
        .init(id: 11, name: "푸드・드링크"),
        .init(id: 12, name: "자연・환경"),
        .init(id: 13, name: "리빙・인테리어"),
        .init(id: 14, name: "미술・디자인・전시"),
        .init(id: 15, name: "음악"),
        .init(id: 16, name: "게임"),
        .init(id: 17, name: "콘서트・공연"),
        .init(id: 18, name: "문화"),
        .init(id: 19, name: "문학・도서"),
        .init(id: 20, name: "언어"),
        .init(id: 21, name: "영화"),
        .init(id: 22, name: "지역・여행"),
        .init(id: 23, name: "가족"),
        .init(id: 24, name: "쇼핑"),
        .init(id: 25, name: "반려동물"),
        .init(id: 26, name: "사회공헌")
    ]

    public let industries: [SelectableItem] = [
        .init(id: 2, name: "IT・게임・통신"),
        .init(id: 3, name: "F&B"),
        .init(id: 4, name: "건설・건축"),
        .init(id: 5, name: "광고"),
        .init(id: 6, name: "교육"),
        .init(id: 7, name: "금융・부동산"),
        .init(id: 8, name: "문화・예술・엔터테인먼트"),
        .init(id: 9, name: "미디어・출판"),
        .init(id: 10, name: "생산・제조"),
        .init(id: 11, name: "생활・서비스"),
        .init(id: 12, name: "유통・무역"),
        .init(id: 13, name: "의료"),
        .init(id: 14, name: "패션"),
        .init(id: 15, name: "자영업"),
        .init(id: 16, name: "기타")
    ]

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
