# Plan: 공통 선택 목록과 앱 시작 책임 분리

## 영향 모듈

App, Shared, DesignSystem, Auth, Explore, MyPage. 새 모듈·외부 의존성 없음.
Shared 테스트 타깃과 하네스를 기존 Project.module helper로 추가한다.

## 설계

- Shared: 기존 SelectableItem과 SelectableCategoryType을 재사용한다. SelectableOptions와 조회 프로토콜을 추가한다.
- SelectableItemStore: 기존 @Observable/@MainActor 격리를 유지해 목록·준비 상태를 소유한다. loadIfNeeded는 성공한 목록이 없을 때 직접 async 조회한다.
- 요청은 화면의 .task 수명을 따른다. 별도 Task·actor·continuation·요청 병합은 만들지 않는다. 동시에 최초 진입한 소비자의 중복 GET은 허용하며, 성공 후에는 재조회하지 않는다.
- App DI: NetworkService로 GET /options를 호출하는 구현을 조립해 하나의 저장소를 모든 소비 Feature에 주입한다. 초기화 자체는 네트워크를 시작하지 않는다.
- Explore의 옵션 API·DTO·모델·조회 유스케이스와 Builder의 preload 진입점은 참조 확인 후 제거한다.
- ViewModel은 저장소 준비를 요청하고 상태를 노출한다. View는 .task로 수명에 묶인 준비를 호출한다. 오류는 해당 영역에서 재시도하며 목록·추천 조회 오류와 섞지 않는다.
- Auth의 산업/관심사, MyPage의 편집 화면, Explore 필터 sheet에서 필요한 영역만 준비한다. 프로필 편집의 이름 표시도 준비 상태를 먼저 확인한다.
- 앱 루트는 세션 복원 후에만 탭을 구성한다. 고정 sleep과 옵션 preload를 제거하고 기존 인증·온보딩 경로를 보존한다.

## 의존성 / 외부 연동

NetworkKit → Shared를 유지한다. Shared → NetworkKit 또는 Feature → 다른 Feature 의존성을 추가하지 않는다.
GET /options의 필드·메서드·인증 이벤트 정책은 유지한다.

## 엣지 케이스 / 에러 처리

- 빈 목록은 성공 상태로 보존하고 선택 화면에서 별도 안내한다.
- 각 목록 내 ID 중복·빈 이름은 잘못된 데이터로 처리하며 부분 목록을 게시하지 않는다.
- 조회 실패는 재시도 가능하고 취소는 사용자 오류로 표시하지 않는다.
- 지연 응답은 사용자가 편집 중인 선택을 초기화하지 않는다. 이미 저장된 프로필 ID는 목록 조회와 별도로 보존한다.

## 위험 / 트레이드오프

스플래시 종료는 기사 준비 완료를 뜻하지 않는다. 실제 시간 개선율은 별도 계측 없이는 주장하지 않는다.
임의의 background preload와 별도 요청 수명 관리자를 만들지 않는다.
