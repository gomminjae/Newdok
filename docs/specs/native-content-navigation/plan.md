# 설계

App의 탭 선언을 iOS 18부터 지원하는 typed Tab API로 정리한다. 기존 5개 값의 raw value는 유지하고 search 값을 마지막에 추가한다. 분리 표시가 확인된 iOS 27에서만 검색 탭을 추가한다.

AppRouter가 검색 진입 직전 탭과 entry_point를 선택 변경 전에 저장한다. SearchStack과 SearchRoute는 기존 Search/Detail Builder를 재사용한다. 인증 완료·로그아웃 초기화에 검색 경로를 포함한다. 게스트와 인증 상태가 바뀌면 검색 루트의 View 수명도 갱신해 이전 검색 결과와 계측 문맥을 새 인증 상태에 재사용하지 않는다.

Feature의 검색 진입 callback을 optional로 받는다. 시스템 검색 탭이 있는 App 조립에서는 상단 버튼을 생략하며, 구버전·Example에서는 기존 callback과 아이콘을 유지한다.

아티클은 기존 직접 배치 HStack을 ToolbarItem/ToolbarItemGroup으로 교체한다. 본문 로딩·읽기·하이라이트·북마크 소유권은 변경하지 않는다. 새 SDK나 모듈·커스텀 유리 배경·오버레이 탭바는 추가하지 않는다.

## 확인 근거

- 설치 Xcode 27.2 SDK에서 TabRole.prominent의 iOS 27 availability를 확인했다.
- 임시 SwiftUI 앱을 Duo/iOS 27.2에 실행해 5개 주요 탭과 분리된 검색 버튼이 함께 표시되는 것을 확인했다. 임시 앱은 저장소 소스·배포 대상이 아니다.
- [Apple TabRole.prominent](https://developer.apple.com/documentation/swiftui/tabrole/prominent), [TabRole.search](https://developer.apple.com/documentation/swiftui/tabrole/search).
