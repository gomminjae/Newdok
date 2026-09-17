# Plan: 아티클 Live Activity

> **어떻게.** 아티클 상세 모듈은 프로토콜만 알고, App이 ActivityKit 구현을 조립하며, 기존 위젯 extension이 Live Activity UI를 함께 제공한다.

## 영향 모듈

- `Modules/Shared`: App과 Widget Extension이 공유하는 `ActivityAttributes` 모델
- `Modules/Features/Detail/Domain`: Live Activity publisher 프로토콜
- `Modules/Features/Detail`: fetch 성공 시 publisher 호출 및 DI 주입
- `Modules/App`: ActivityKit publisher 구현, 로그아웃 종료, Dynamic Island deep link 라우팅
- `Modules/NewdokWidget`: `ActivityConfiguration`의 Lock Screen·Dynamic Island UI
- `docs/specs/article-live-activity`: 기능 스펙과 작업 기록

## 설계

`Shared`에 아티클 ID·브랜드명·제목을 immutable attributes로 두고, `읽는 중` 상태와 작은 정사각형 뉴스레터 썸네일 데이터를 `ContentState`에 둔다. 앱은 현재 활동과 같은 아티클이면 재사용하고, 다른 아티클이면 기존 활동을 즉시 종료한 뒤 새 아티클 활동을 요청한다. 이미지 URL은 앱에서 검증·다운로드한 뒤 64px JPEG 썸네일로 축소해 활동 상태에 넣는다. 요청이나 이미지 다운로드가 실패해도 본문 읽기를 막지 않는다.

Detail Domain의 `ArticleActivityPublishing`은 `@MainActor` async 프로토콜로 둔다. `ArticleDetailViewModel`은 상세 fetch 성공 또는 캐시된 상세의 재등장 시 publisher를 호출한다. AppRouter의 현재 아티클 경로를 기준으로 publisher가 시작을 허용하고 경로 이탈 시 종료한다. 화면의 `onDisappear`나 백그라운드 전환은 종료 조건으로 사용하지 않는다. 과거 아티클도 지원하며 attributes와 deep link의 `past=true`로 모드를 보존한다. Example과 테스트는 기본값 `nil`을 사용해 ActivityKit을 요구하지 않는다.

상세 API 요청과 웹뷰 첫 렌더링 상태는 ViewModel에서 연결한다. 상세를 할당하기 전에 웹뷰 로딩 상태를 설정하고 navigation 완료·실패에서 해제한다. 취소된 요청은 상세 상태를 덮어쓰지 않는다.

썸네일은 배율 1로 만들고 인코딩된 attributes/state 합계가 4KB 미만인 데이터만 전달한다. 해상도와 JPEG 품질을 순차 조정하고 제한 안에 들어오지 않으면 대체 아이콘을 유지한다. 비동기 단계마다 현재 아티클과 요청 세대를 확인해 이전 화면의 요청을 폐기한다.

Widget Extension은 기존 `NewdokWidgetBundle`에 `ActivityConfiguration`을 추가한다. compact는 왼쪽 브랜드 이미지와 오른쪽 브랜드명 한 줄(끝 말줄임), minimal은 이미지, expanded는 상단 이미지·브랜드명 및 하단 제목 두 줄을 표시한다. Lock Screen은 이미지·브랜드명·제목을 표시한다. `읽는 중` 상태 모델은 기존 데이터 호환을 위해 유지하되 UI에는 표시하지 않는다. 이미지가 로드되지 않으면 SF Symbol 대체 아이콘을 사용한다. 링크는 `newdok://article/<id>`에 지난 아티클 모드를 보존한다.

`NewdokApp`은 URL host가 `article`인 링크를 받아 `AppRouter`의 홈 경로에 아티클 상세 route를 설정한다. 로그아웃 시 App publisher가 모든 활동을 종료한다.

## 의존성 / 외부 연동

- 새 외부 의존성은 추가하지 않는다.
- 시스템 프레임워크 `ActivityKit`만 App, Shared, Widget Extension에서 사용한다.
- App과 Widget Extension 타깃의 `NSSupportsLiveActivities` 및 기존 App Group/서명 설정을 유지한다.

## 엣지 케이스 / 에러 처리

- `Activity.request` 실패는 로컬 상태를 남기지 않고 읽기 흐름을 계속한다.
- 같은 아티클을 재시도해도 중복 활동을 만들지 않는다.
- 다른 아티클로 전환하면 이전 활동을 `.immediate` 정책으로 종료한다.
- URL의 아티클 ID가 비어 있거나 숫자가 아니면 기존 URL 처리만 수행한다.
- Live Activity에 본문 HTML이나 개인정보를 저장하지 않는다. 공개 뉴스레터 브랜드 이미지의 축소 데이터만 상태에 저장한다.

## 위험 / 트레이드오프

- Live Activity 표시 시간과 갱신 예산은 시스템 정책을 따른다.
- 현재는 로컬 시작만 지원하며 서버 기반 push-to-start/update는 범위에서 제외한다.
- 실제 Dynamic Island 렌더링은 지원 기기 또는 해당 기능을 제공하는 시뮬레이터에서 검증한다.
