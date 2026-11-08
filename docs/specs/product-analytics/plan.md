# Plan: 사용자 행동과 이탈 분석

> Status: approved — 2026-11-08 구현 시작. [spec.md](spec.md)의 승인 범위를 따른다.
> 지표는 [metrics.md](metrics.md), 이벤트는 [events.md](events.md)가 기준이다.

## 영향 모듈

| 경계 | 필요한 변경 |
|---|---|
| Shared | 타입이 있는 이벤트·enum·필요 문맥·기록 인터페이스, 비활성/테스트 기록기 |
| App | Firebase 어댑터·환경·수집·인증 문맥 조립, 기존 Builder 주입 |
| Auth | 화면 단계·인증 시도·가입·프로필·게스트 계측. Auth 흐름 ID만 전달 |
| Home | 콘텐츠 상태·안내 선택. 회복 ID를 다른 Feature까지 전파하지 않음 |
| Detail | 기사 표시·열람·북마크 변경·하이라이트 적용, 뉴스레터 상세·구독 시도 수명 |
| Explore·Search·Subscribe·Bookmark | 목록 상태·선택의 문맥. 검색은 같은 목록 ID 사용 |
| DesignSystem | 구독 루트 WebView의 표시 성공·실패·종료 callback. SDK 의존 없음 |
| Interface·Builder·DI·Testing·Example | 실제 소비자가 필요한 의존성·문맥만 전달. Example·테스트는 SDK 비전송 |

새 모듈·패키지는 추가하지 않는다. App의 기존 FirebaseAnalytics를 재사용하며 App→Feature→Core→External 방향을 유지한다.
도입을 위해 기능마다 옵션 플래그·추상 factory·범용 이벤트 버스를 만들지 않는다.

## 확인한 코드 기준

- Modules/App/Sources/NewdokApp.swift에 Firebase 초기화가 있다.
- Modules/App/Sources/DI/AppDependencies.swift·AppContainer.swift가 기존 공통 의존성과 Builder 조립 경계다.
- SignupView에는 계정 생성 뒤 프로필·추천 건너뛰기 분기가 있다. submitInterests는 저장 완료 전 추천 화면으로 이동한다.
- HomeView의 guest/noSubscriptions/noArticles/articles와 오류 표시를 구분해야 한다. failed 노출은 실제 serverErrorPopup이 보이는 serverError에 한정하고, 그 외 요청 오류는 operation_failed와 구분한다.
- ArticleWebView의 성공·실패·프로세스 종료가 모두 로딩 bool을 변경하므로 성공 callback을 분리해야 한다.
- BrandDetailView와 Signup의 CurationRow가 각각 외부 구독을 연다. WebView Coordinator는 팝업도 처리한다.
- SearchViewModel은 뉴스레터 검색이며 generation·취소 확인 뒤 최신 결과를 채택한다.

CodeGraph 조회와 원문·Builder를 대조했고 구현 뒤 인덱스를 갱신했다. 범위 검증은 Swift 522개·인덱스 파일 534개, 누락·중복·제외 경로 없음으로 통과했다.
기존 생성물·사용자 데이터·로컬 설정의 unrelated 수정은 보존한다.

## 최소 구현 설계

### 타입·SDK 경계

- Shared의 AnalyticsEvent: Sendable과 enum은 현재 23개 이벤트만 표현한다. 대기 후보 case·임의 확장 딕셔너리는 만들지 않는다.
- 기록 인터페이스는 @MainActor로 격리해 발생 문맥을 동기 전달한다. 전송 완료를 기다리는 API·별도 Task·lock을 만들지 않는다.
- Shared는 이벤트 계약의 타입 있는 String/Int payload와 검증을 제공하고, App 어댑터만 이를 SDK 딕셔너리로 변환해 logEvent·수집 API를 호출한다. Feature·Domain에 SDK 타입을 노출하지 않는다.
- AppDependencies→AppContainer→Builder/DI→소비자에 주입한다. 운영 주입 누락을 기본 no-op로 숨기지 않는다.
- SDK 전송 큐·재시도는 재구현하지 않는다. 잘못된 payload는 비전송하고 제품 기능을 계속한다.

### 수명·중복

- 전역 이벤트 UUID·화면 방문 UUID를 만들지 않는다. 실제 표시 전환·연속 노출 중복은 기존 화면의 최소 로컬 상태로 제어한다.
- Auth는 auth_flow_id·auth_attempt_id, 목록은 list_view_id, 상세는 article_view_id 또는 newsletter_view_id,
  구독 화면은 subscription_attempt_id만 관련 수명에 둔다. 임의 공용 ID 관리자·영구 저장소는 만들지 않는다.
- 검색 요청 시작에 목록 문맥 ID를 만들고 최신 응답·실제 표시·선택·목적지까지 유지한다. 요청별 별도 검색 ID를 추가하지 않는다.
- 선택은 item_id와 원래 목록 ID로 연결한다. M04는 세션 전환이므로 선택마다 또 UUID를 만들 필요가 없다.
- 업무 내부의 취소·generation·소유권 검사는 유지한다. 분석 ID를 줄인다고 오래된 결과·중복 UI 작업을 허용하지 않는다.
- 성공은 유효한 상태 반영 뒤, 노출은 실제 보인 뒤 기록한다. 캐시 노출은 서버 성공으로 부르지 않는다.
- 로그인 성공은 E06, 그 외 인증 종료는 E05다. 같은 인증 성공을 두 이벤트로 보내지 않는다.
- 화면 복귀 때 SDK 화면 문맥은 맞추고 단계는 E01 step_key로 구분한다. 자동 화면 수집과 중복이면 App manifest에서 조정한다.
  [Firebase 화면 측정](https://firebase.google.com/docs/analytics/screenviews)

### 기사·구독

- 기존 WebView에 성공/실패 사실을 전달하는 최소 callback을 둔다. 로딩 false만으로 E17을 보내지 않는다.
- 현재 Detail 관찰 상태가 열람을 소유한다. UI가 scene 활성·본문 가시성을 전달하고 단조 시계로 활성 시간만 누적한다.
- 구조화된 .task(id:) 등으로 임계점만 기다린다. 비가시·로딩·배경·폐기 시 취소/정지한다. 초 단위 전송이나 추가 WebView 보유는 하지 않는다.
- 가짜 시계로 테스트하고 실제 30초 도달 시 E18을 한 번 기록한다. rule과 active_visible_ms를 함께 검증한다.
- 상세와 가입 추천이 같은 구독 시도 타입을 사용한다. 가입 추천의 상태는 unknown, 팝업 didFinish는 루트 성공과 분리한다.
- 외부 페이지 복귀·기존 confirmed·구독 재개를 신규 구독 완료로 기록하지 않는다.
- 북마크는 use case 성공과 실제 상태 변경 뒤 E27을 기록한다. 현재 bookmark()가 Void를 반환하므로 View에서 await 종료·토스트를 성공 근거로 쓰지 않는다.
- 하이라이트는 addHighlight 저장 성공 직후 E28을 기록한다. 저장 뒤 목록 재조회, 선택·색상 편집·복원과 구분한다.
  현재 Repository는 선택 원문·기사 제목을 다루지만 분석 이벤트에는 해당 값을 전달하지 않는다.
- 상세 응답의 brandId·brandName을 검증해 newsletter_id·선택적 newsletter_name으로 사용한다. 공개 이름은 100자 초과/누락 시 생략한다.

### 환경·신원

- 개발/상용 Firebase 연결·스트림·자동 수집·기존 사용자 수집 선택을 먼저 확인한다. 실제 ID·키·설정을 출력하거나 덮어쓰지 않는다.
- 환경 태그만으로 자동 이벤트가 제외된다고 가정하지 않는다. 기존 분리를 유지하거나 검증된 개발 수집 제외 방식을 정한다.
- SDK default에는 정적 환경·빌드만 둔다. 동적 ID·인증·화면은 발생 시점의 payload에만 넣는다.
- SDK 앱 인스턴스가 초기 사용자 단위다. 추가 영구 설치 UUID·광고 식별자를 수집하지 않는다.
- User-ID는 허용된 내부 ID와 운영 필요가 확인된 경우만 연동한다. P0 필수는 아니다.
  연동한다면 로그인 확정 전후 순서와 로그아웃·게스트·세션 만료·탈퇴 해제를 일치시킨다. 이메일·토큰·이메일 해시는 쓰지 않는다.
- 개발 DebugView로 검증한다. debug 모드만으로 운영 보고서·원시 데이터 제외가 보장된다고 가정하지 않는다.
  [수집 설정](https://firebase.google.com/docs/analytics/ios/configure-data-collection?platform=ios),
  [DebugView](https://firebase.google.com/docs/analytics/debugview), [User-ID](https://firebase.google.com/docs/analytics/userid)

## 보고서·외부 연동

GA4에서 화면·이벤트 개요, 정상 분기별 퍼널, 코호트를 먼저 제공한다. 필요한 custom definition만 등록한다.
SDK 이벤트 기록만으로 보고서 완료를 주장하지 않는다. 키 이벤트 설정도 운영 필요가 있을 때만 한다.
기간·콘텐츠/조회 ID를 정확히 결합하는 산식은 원시 데이터로 검증한다. GA4 순서 퍼널은 같은 계산이라고 가정하지 않는다.

기존 BigQuery 연결·가용 시작일을 읽어 확인한다. 신규 연결·비용·위치·보존 변경은 별도 요청 범위다.
이전 데이터가 모두 복구된다고 가정하지 않는다. 준비 안 된 지표는 미측정/관찰 중으로 표시한다.
[GA4 퍼널](https://support.google.com/analytics/answer/9327974?hl=en),
[BigQuery](https://firebase.google.com/docs/projects/bigquery-export)

화면·기능 이용, 뉴스레터 이용, 이탈·유지의 세 보고서를 metrics.md의 정의로 구성한다.
화면은 SDK 이름 차원을 재사용하고 기능은 대표 실제 행동으로 집계한다. 최초 홈 도달을 자발적 기능 사용으로 바꾸지 않는다.
검색 기능 사용은 E14로 측정하므로 결과 실패/취소도 포함되며 성공 결과 기반 M10과 분모를 구분한다.
보고서에는 기능별 대표 행동 수준을 명시하고 같은 시도율·성공률·품질 순위처럼 비교하지 않는다.
entry_point는 직전 진입 경로이며 최초 발견 기여로 표시하지 않는다.
뉴스레터별로 기존 E17의 본문 조회 사용자 M18과 30초 유효 독자 M14를 병기한다. 짧은 기사의 기준 편향을 함께 해석한다.

뉴스레터별 분해에 현재 소비자가 생겼으므로 newsletter_id와 필요한 공개 newsletter_name은 기존 quota·값 수를 확인해
이벤트 범위 custom dimension으로 등록한다. 공개 이름은 표시 보조값이며 이름 변경·동명이름을 ID로 정규화한다.
필요하면 기존 공개 카탈로그/원시 데이터로 최신 표시명을 연결하되 별도 범용 동기화 플랫폼은 만들지 않는다.
개별 기사·연결 UUID는 그대로 원시 분석용이며 사용자 입력/본문을 수집하지 않는다.
방문자·독자·조회·구독 시도·저장 행동을 분리하고 실제 구독자/현재 저장 보유량/개별 카드 CTR은 근거 없이 제공하지 않는다.
[GA4 맞춤 정의](https://support.google.com/analytics/answer/14240153?hl=en)

## 확장 절차

1. 질문·결정·산식을 metrics.md에 먼저 등록한다. 현재 데이터로 계산되면 수집을 늘리지 않는다.
2. 새 사실만 events.md에 소유자·필드·수명·중복·사용처와 함께 추가한다. SDK 자동 정보·동의어 ID는 재사용한다.
3. 선택 필드 추가는 이전 값이 없어도 소비자가 동작하게 한다. 의미·단위·필수 조건 변경은 event_version을 올린다.
4. 지표 분모·기간·열람 기준 변경은 definition_version을 올린다. rule·이벤트 버전·적용 빌드·시작일과 연결한다.
5. 구버전 앱이 계속 전송하므로 지원 버전 필터·보고서 정의를 명시한다. 폐기 계약은 대체 항목과 남긴다.
6. 문서·enum·변환·계약 테스트·보고서 설정을 함께 맞춘다. 가상의 provider·확장 슬롯·후속 설정 플래그는 만들지 않는다.

## 최소 수집·확장성 판단 기록

> 2026-11-08 결정. 미배포 스펙의 최소성 재검토 결과이며 운영 데이터의 계약 변경은 아니다.

이 설계에서 확장성은 필드를 미리 많이 수집하는 것이 아니라, 새 측정을 추가할 위치와 호환 규칙이 명확하다는 뜻이다.
필드 수가 SDK 한도 안이라는 사실만으로 필요성을 인정하지 않는다.

| 결정 | 현재 필요한 이유 | 새 요구가 생겼을 때 |
|---|---|---|
| 공통 필드는 5개 | 계약·환경·도입 빌드·인증 상태·진입 경로가 현재 비교와 수집 검증에 필요 | 새 공통 필드는 여러 이벤트의 현재 소비자를 확인한 뒤 추가. 특정 기능에만 필요하면 해당 이벤트에만 둠 |
| 연결 ID는 6종·관련 수명에 한정 | 가입 분기/인증 시도, 목록→열람, 상세→구독, 구독 화면의 현재 산식에 필요 | 기존 ID로 연결되지 않는 새 분석이 있어야 새 ID를 추가. UUID 생성·보존·전달 범위와 비용을 함께 정의 |
| 전역 이벤트·화면 방문 ID 제외 | 현재 사용자·세션·조회 지표는 각 단위의 중복 제거와 실제 발생 제어로 충분 | 이벤트별 전달 추적이나 별도 방문 지표가 필요할 때 근거를 정함. 새 ID가 SDK 전달 보장을 만들지는 않음 |
| 노출 중복 통합 | 화면/단계는 E01, 정상/빈 목록은 E13으로 현재 퍼널을 측정할 수 있음 | 다른 사실·다른 시점이 필요한 경우에만 별도 이벤트. 같은 사실이면 선택 필드 검토 |
| 가입 성공·인증 종료 중복 제외 | login과 그 외 종료를 나누면 현재 인증 결과를 한 번씩 표현할 수 있음 | 분석 편의를 위해 같은 성공을 추가 이벤트로 복제하지 않음 |
| 검색·로드·선택·저장의 별도 UUID 제외 | 목록 ID와 item_id·현재 상세 ID, 가입 흐름 ID로 현재 산식이 연결됨 | 현재 지표로 구분 불가능한 개별 시도 분석이 실제 필요할 때 추가 |
| 홈 안내 선택과 실제 회복 구분 | 지금은 사용자가 안내를 선택했는지만 측정하면 됨. 다른 Feature까지 회복 ID를 전달할 필요가 없음 | 회복 성공을 의사결정에 사용할 때 별도 지표·연결·종료·교란 조건을 설계. 기존 선택률을 회복률로 이름만 바꾸지 않음 |
| 신규 구독 완료 계약 대기 | 외부 페이지 종료·현재 confirmed만으로 최초 완료를 검증할 수 없음 | Q-03의 서버 근거·귀속·재개 제외를 확인하고 계약부터 추가. 대기 enum case·저장소는 미리 만들지 않음 |
| 현재 23개 타입·단일 SDK 어댑터 | 현재 기능에 필요한 계약과 Firebase 구현을 분리할 수 있음 | 새 이벤트는 enum·변환·테스트를 추가. SDK 변경이 필요하면 App 어댑터를 수정하며 다중 provider 체인은 미리 만들지 않음 |
| 이벤트·지표 버전 분리 | payload 구조와 제품 지표의 분모·기간·열람 기준은 서로 다르게 바뀔 수 있음 | 지원 버전·적용 시점·보고서 필터를 명시하고 이전 값과 비교 범위를 결정 |

의도적으로 제외한 정보는 나중에 과거 데이터에서 만들어낼 수 없다. 추후 정밀 분석은 새 수집 시작일부터 제공한다.
실제 구독 완료·정확한 홈 회복·재시도별 분석의 현재 미지원은 이 최소 범위의 한계로 명시한다.

필드 추가 시에는 다음 네 가지를 검토 기록에 남긴다.

1. 현재 결정할 제품 질문과 사용하는 지표 또는 오류 진단.
2. 기존 이벤트·SDK 정보·연결 ID로 계산할 수 없는 이유.
3. 타입·정보 범위·수명·중복·필수 조건과 실제 소비 보고서.
4. 과거 버전 호환·수집 시작일·검증 기대값·추가 구현 비용.

이 중 사용처와 기존 데이터의 부족 이유가 없으면 추가하지 않는다. 이는 가상의 미래 사용처를 위한 설계를 제한하는 기준이다.

이번 화면·기능·뉴스레터 이용 질문이 생겨 E14 검색 시작과 E27/E28 저장 성공을 추가했다.
검색 결과만으로 실제 실행 이용을 알 수 없고, 화면 노출만으로 북마크·하이라이트 사용을 알 수 없다는 현재 부족을 해결한다.
newsletter_name은 GA4 보고서의 읽을 수 있는 라벨에 필요하다. 새 공통 필드·UUID·게시자별 이벤트 이름은 추가하지 않았다.

## 검증·완료 근거

- 계약: 이름·허용 타입·필수/조건부·조합·원문 미포함·전체 키 수를 검증한다. 현재 최대 13개, SDK 한도 25개다.
- 흐름: 기록기로 성공/실패/취소/응답 역전/계정 변경/복귀 중복을 확인한다.
- 열람: 가짜 시계로 29초/30초·배경·로딩·재로드·조회 교체를 검증한다. 실제 네트워크·임의 sleep은 사용하지 않는다.
- 집계: 합성 데이터로 누락·중복·0 분모·미성숙·경계 시각·다른 콘텐츠 혼입의 기대값을 확인한다.
- M06·M08은 최초 진입 후 24시간 완료 분모만 집계하고 미성숙 성공도 같은 기준으로 제외한다.
- 원시 데이터의 기간용 시각·업로드 시차·최초 실행 시각과 동일 timestamp 내 배치 순서를 실제 iOS export로 검증한다.
  시각 대소만으로 순서를 증명하거나 사건 이름으로 임의 정렬하지 않는다. 미확인 경로는 분리해 보고한다.
- 이용 분석: 한 사람의 반복 열람과 여러 독자, 화면 도달과 기능 행동, 실패 검색과 성공 검색, 저장 추가와 현재 보유량을 구분한다.
  동일 이름의 다른 ID·이름 변경·공개 라벨 누락·북마크/하이라이트 실패에서 기대 집계를 검증한다.
- Core·여러 Feature 변경이므로 ./scripts/test.sh와 Release fastlane build를 수행한다. 필요한 새 테스트 타깃은 Tests·test.sh·scheme을 루트 하네스에 맞춘다.
- manifest/의존성 변경 시 mise exec -- tuist install 및 mise exec -- tuist generate --no-open을 수행한다. 생성 pbxproj는 커밋하지 않는다.
- 새 모듈은 예정하지 않는다. 필요해지면 codegraph.json과 python3 scripts/check-codegraph.py 검증을 포함한다.
- 실제 개발 DebugView·수집 제외·적용 빌드·T0·완료 AC·미측정 항목을 기록한다. 업로드는 별도 요청 작업이다.

## 위험 / 트레이드오프

열람 시간은 대리 지표이고 앱 인스턴스는 사람이 아니다. SDK 전달 누락·외부 구독·발행 지연을 완전히 관측할 수 없다.
초기에는 홈 안내 이후 실제 회복과 개별 요청 재시도 분석을 제공하지 않는다. 선택률·오류 현황과 구분한다.
정확한 원시 집계가 준비되지 않으면 GA4 개요의 제한을 명시한다. 기능별 수집 시작일이 다른 버전을 같은 퍼널로 비교하지 않는다.

전체 검토 결과와 수정/보류 근거는 [review.md](review.md)에 기록한다.

## 구현 확인 사항

- 현재 GoogleService 설정은 상용 번들용 하나이며 기존 분석 수집은 활성이다. 개발용 Firebase 설정은 없다.
- manifest에서 자동 화면 수집과 초기 Analytics 수집을 비활성화하고, App은 검증된 상용 Release 번들에서만 수집을 활성화한다. 개발 빌드는 상용 프로젝트에 전송하지 않는다.
- 개발용 실제 DebugView는 올바른 개발 Firebase 연결이 준비된 뒤 검증한다. 이번 구현은 SDK 비전송 기록기·계약/흐름 테스트와 빌드로 검증하고 이 제한을 남긴다.
- 분석 인터페이스는 Sendable 값 타입 AnalyticsClient와 MainActor 기록 클로저로 주입한다. 새 테스트 앱 타깃 대신 Shared의 순수 payload·열람 상태와 Feature의 실제 결과 경계를 테스트한다.

## 구현 결정 — 2026-11-08

- 브랜치: `feat/product-analytics`. 미배포 1.1.1(빌드 1) 소스 기준이며 수집 T0는 아직 없다.
- `Shared/Sources/Analytics`에 23개 이벤트, 제한된 scalar payload 검증, 화면·콘텐츠 상태 표시 modifier, 기사 활성 시간, 외부 구독 시도 수명을 둔다. Firebase SDK 변환과 실제 전송은 App에만 둔다.
- App은 모든 Builder에 기록기를 명시적으로 주입한다. Feature Interface는 Shared의 목록/진입 문맥만 받으며 Firebase를 참조하지 않는다. ViewModel의 비활성 기본값은 기존 단위 테스트·Example에 사용한다.
- App 탭·NavigationStack의 마지막 경로·인증 cover·업데이트 팝업이 실제 표시 범위를 전달한다. 인증 흐름의 첫 홈 표시에는 auth_flow_id를 한 번 연결한다.
- 목록 ID는 날짜·검색·필터·새 결과의 문맥에 둔다. 캐시 복귀와 상세로 전달할 때 같은 값을 유지한다. 취소·대체·계정 변경 검사는 내부 요청 소유권이며 wire의 별도 UUID 필드가 아니다.
- Article WebView는 `loadHTMLString`이 반환한 현재 WKNavigation의 성공을 식별한다. 실패·외부 링크 로드·프로세스 종료를 표시 성공으로 바꾸지 않는다. 숨겨진 화면의 성공은 가시 상태로 돌아올 때 기록한다.
- 읽기 시간은 ContinuousClock.Instant를 입력받는 값 타입으로 계산한다. 테스트는 실제 대기 없이 시각을 전진시킨다. 화면의 구조화된 task는 남은 임계 시간만 기다리고 배경·가림막·상세 이탈에서 정지한다.
- 북마크는 성공 여부를 반환해 실패 토스트도 방지한다. 하이라이트는 기존 저장 성공 직후만 기록한다. 선택 텍스트·기사 제목·이메일·URL·원시 오류는 payload API에 없다.
- 외부 구독은 상세/가입 추천에서 같은 session 타입을 쓴다. root WebView callback과 sheet/fullScreenCover의 onDismiss를 연결하고, callback은 생성 당시 시도를 캡처한다. 팝업·중복 callback·닫힌 시도의 늦은 callback은 추가 성공을 만들지 않는다.

### Firebase 실행 환경

로컬 리소스는 상용 번들용 하나뿐이며 별도 개발 Firebase 설정과 기존 수집 선택 UI는 코드에서 찾지 못했다. 기존 비밀 설정 파일은 수정하지 않는다.

- Info.plist의 초기 수집은 꺼져 있고 자동 화면 측정도 끈다.
- Debug는 build setting으로 `FIREBASE_ANALYTICS_COLLECTION_DEACTIVATED`를 활성화하고 어댑터도 비활성화한다. 이전 실행에서 저장된 수집 허용값이 있어도 개발 자동 이벤트가 상용으로 흘러가지 않게 한다.
- Release는 실제 앱 번들과 Firebase 옵션의 번들이 모두 상용 앱과 일치할 때만 수집을 켠다.
- Tuist가 plist에 치환하는 YES/NO 문자열의 판정은 설치 SDK 12.19.1의 FIROptions.isAnalyticsCollectionDeactivated가 boolValue로 읽는 경로를 확인했다. 빌드 산출물에서도 치환 결과를 확인한다.
- 이는 개발 Firebase를 새로 만든 것이 아니다. 현재 Debug 빌드에서 DebugView 수신을 검증했다고 주장하지 않는다. 개발 앱 등록/설정과 콘솔·원시 export 확인은 외부 설정 단계에 남는다.

수집 토글의 지속성과 비활성 우선순위는 [Firebase 공식 수집 설정](https://firebase.google.com/docs/analytics/ios/configure-data-collection?platform=ios)을 대조했다.
