# 📄 월별 데이터 프리패칭, 캐싱, 최신 요청 동기화 전략 (Newdok 프로젝트)

## 1. 목적

- 달력 기반 아티클 뷰에서 월 이동/날짜 클릭 시 느린 렌더링, 데이터 불일치(race condition) 문제를 해결
- **월별 데이터 캐싱**과 **프리패칭**, **최신 요청만 반영**하는 동기화 전략 적용

---

## 2. 구조 및 동작 방식

### 2.1. 월별 데이터 캐싱
- `@Published var monthlyCache: [String: [Articles]]`
  - key: "yyyy-MM" (예: "2024-04")
  - value: 해당 월의 `[Articles]` 배열
- 이미 받아온 월은 API 호출 없이 캐시에서 즉시 사용

### 2.2. 프리패칭(Pre-fetching)
- 월별 데이터 로드 후, 인접 월(이전/다음 월)도 미리 받아둠
- 사용자가 월을 넘길 때, 이미 데이터가 준비되어 있어 빠른 렌더링 가능

### 2.3. 최신 요청만 반영 (Race Condition 방지)
- 빠르게 월을 넘길 때, 마지막으로 요청한 월 데이터만 반영
- 각 요청마다 고유 key(yyyy-MM)를 latestRequestKey에 저장
- API 응답이 왔을 때, latestRequestKey와 일치하는 경우에만 데이터 반영

---

## 3. 실제 코드 예시 (HomeViewModel)

```swift
@Published public var monthlyCache: [String: [Articles]] = [:]
@Published var currentMonthKey: String = ""
private var latestRequestKey: String = ""

public func loadArticles(for date: Date) async {
    let year = formatYear(date)
    let month = formatMonth(date)
    let key = "\(year)-\(month)"
    currentMonthKey = key
    latestRequestKey = key
    if let cached = monthlyCache[key] {
        self.articlesByMonth = cached
        self.filterArticles(by: date)
        return
    }
    do {
        let monthly = try await useCase.fetchMonthlyData(year: year, month: month)
        // 최신 요청만 반영
        if latestRequestKey == key {
            self.articlesByMonth = monthly
            self.monthlyCache[key] = monthly
            self.filterArticles(by: date)
            Task { await prefetchAdjacentMonths(for: date) }
        }
    } catch {
        print("❌ Monthly fetch failed: \(error)")
    }
}

private func prefetchAdjacentMonths(for date: Date) async {
    let calendar = Calendar.current
    if let prev = calendar.date(byAdding: .month, value: -1, to: date) {
        let key = "\(formatYear(prev))-\ 