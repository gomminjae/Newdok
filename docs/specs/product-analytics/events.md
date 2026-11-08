# Events: 사용자 행동과 이탈 분석

> Status: implemented locally — 승인된 v1의 23개 이벤트를 구현하고 전체 테스트·Release 빌드를 검증했다. 실제 SDK 수신과 수집 T0는 미확인이다.
> 지표는 [metrics.md](metrics.md), 설계는 [plan.md](plan.md)를 따른다.

## 공통 필드: 5개

| 필드 | 전송 타입 / 값 | 현재 사용 목적 |
|---|---|---|
| `event_version` | Int, 초기 1 | 계약 버전별 지표 비교·잘못된 혼합 방지 |
| `measurement_env` | String: production, development | 개발 검증·수동 이벤트 구분. 자동 수집 제외의 단독 근거는 아님 |
| `app_build` | String, 검증된 CFBundleVersion | 계측 도입·수정 빌드 구분. SDK 마케팅 버전과 별도 |
| `auth_state` | String: unauthenticated, guest, authenticated, unknown | 게스트/회원·인증 상태별 병목 |
| `entry_point` | String(enum) | 해당 화면·흐름을 시작한 제품 경로별 발견·열람·구독 비교 |

사용자·세션·마케팅 버전·OS·기기는 SDK 정보를 재사용한다. SDK 자동 이벤트에 모든 공통 필드가 있다고 가정하지 않는다.
동적 문맥은 발생 시점에 고정하고 전송 시점의 다른 계정·화면 값으로 덮어쓰지 않는다.

entry_point는 launch, onboarding, login, signup, signup_curation, home, explore_recommended, explore_all,
search, subscriptions, bookmarks, newsletter_detail, article_detail, mypage, deep_link, unknown이다.
기사의 표시·열람은 원래 목록 출처를, 구독 페이지는 원래 구독 시작 위치를 유지한다.
이 출처는 해당 흐름의 직전 진입 경로다. 예: 검색→뉴스레터 소개→기사에서는 기사 흐름의 출처가 newsletter_detail이다.
이를 최초 검색 유입이나 전체 경로 기여로 해석하지 않는다.

## 현재 이벤트: 23개

공통 필드는 모든 수동 이벤트에 적용한다. 조건부 필드는 조건이 맞으면 필수다. 각 이벤트는 한 경계에서만 기록한다.
같은 결과를 Repository·ViewModel·View가 따로 보내지 않는다.

| ID / 단계 | 이름 | 발생 사실 / 소유자 | 추가 필수 필드 | 조건부 필드 | 사용 지표·진단 |
|---|---|---|---|---|---|
| E01 / P0 | `screen_view` | 주요 화면·온보딩/가입 단계의 실제 표시 전환 / 표시 경계 | `screen_name` | 온보딩·가입: `step_key`; 인증 흐름과 최초 메인: `auth_flow_id` | M08·M11·화면 경로 |
| E03 / P0 | `onboarding_completed` | 로그인·가입 버튼으로 온보딩 완료 / Auth 완료 경계 | `auth_flow_id`, `next_screen` | 없음 | M08·온보딩 진입 선택 |
| E04 / P0 | `auth_attempt_started` | Apple·Kakao 인증 시작 / Login ViewModel | `auth_flow_id`, `auth_attempt_id`, `method` | 없음 | M08·인증 대기/실패 분모 |
| E05 / P0 | `auth_attempt_finished` | 가입 필요·실패·사용자 취소로 인증 종료 / Login ViewModel | `auth_flow_id`, `auth_attempt_id`, `method`, `outcome` | failed: `error_category` | M08·인증 종료 원인 |
| E06 / P0 | `login` | 기존 회원 인증이 현재 세션에 반영 / 로그인 확정 경계 | `auth_flow_id`, `auth_attempt_id`, `method` | 없음 | M08. 성공은 E05를 추가 전송하지 않음 |
| E07 / P0 | `sign_up` | 신규 계정 생성·현재 사용자 반영 / Signup ViewModel | `auth_flow_id`, `method` | 없음 | M08. 프로필·추천 완료와 구분 |
| E09 / P0 | `profile_setup_finished` | 관심사 저장 성공 또는 명시적 건너뛰기 / 해당 결과 경계 | `auth_flow_id`, `outcome` | 없음 | M08·프로필 분기 |
| E10 / P0 | `guest_started` | 명시적 게스트 선택·상태 반영 / Auth 확정 경계 | `auth_flow_id` | 없음 | M08·게스트 분기. 상태 복원 제외 |
| E12 / P0 | `select_content` | 콘텐츠를 선택해 상세 이동 시작 / 선택 경계 | `content_type`, `item_id`, `list_id`, `list_view_id` | newsletter 선택: `newsletter_id`; 공개 정보 있음: `newsletter_name` | M04·M12·선택 콘텐츠·경로 |
| E13 / P0 | `content_state_viewed` | ready·guest·empty·failed 상태의 실제 노출 / 표시 경계 | `surface`, `state`, `reason` | 데이터 문맥 있음: `list_id`, `list_view_id`; Home: `date_relation` | M04·M09·홈 상태. ready가 정상 목록 노출을 겸함 |
| E14 / P1 | `newsletter_search_started` | 유효 입력으로 실제 검색 시작 / Search ViewModel | `list_view_id`, `query_source` | 없음 | M12. 결과 대기·실패·취소 전에도 검색을 사용한 사실 |
| E15 / P1 | `newsletter_search_finished` | 최신 성공 검색 응답 채택 / Search ViewModel | `list_view_id`, `query_source`, `result_bucket` | 없음 | M10·결과 선택 연결 |
| E16 / P0 | `article_opened` | 기사 상세의 논리적 진입 / Detail 진입 경계 | `article_view_id`, `item_id`, `article_kind` | 목록 경유: `list_view_id` | M04·기사 진입/표시 병목 |
| E17 / P0 | `article_rendered` | 현재 본문 메인 문서 표시 성공·로딩 가림막 해제 / Detail 표시 경계 | `article_view_id`, `item_id`, `article_kind`, `newsletter_id` | 목록 경유: `list_view_id`; 공개 정보 있음: `newsletter_name` | M04·M05·M18·뉴스레터별 표시 성공 |
| E18 / P0 | `article_engaged` | 활성 가시 시간 누적 30초 / Detail 열람 소유자 | `article_view_id`, `item_id`, `article_kind`, `newsletter_id`, `engagement_rule`, `active_visible_ms` | 목록 경유: `list_view_id`; 공개 정보 있음: `newsletter_name` | M01~M05·M12·M14·M15·열람 검증 |
| E19 / P1 | `newsletter_detail_viewed` | 뉴스레터 상세의 첫 정상 표시 / Brand Detail 표시 경계 | `newsletter_view_id`, `newsletter_id`, `subscription_status` | 목록 경유: `list_view_id`; 공개 정보 있음: `newsletter_name` | M06·M13·목록/검색→상세 |
| E20 / P1 | `newsletter_subscribe_started` | 유효한 문맥으로 외부 구독 진입 / 상세 또는 가입 추천 경계 | `newsletter_id`, `subscription_attempt_id`, `subscription_status` | 상세 경유: `newsletter_view_id`; 공개 정보 있음: `newsletter_name` | M06·M12·M16·구독 시도 |
| E21 / P1 | `newsletter_subscribe_page_opened` | 루트 WebView 첫 메인 문서 표시 성공 / 구독 표시 경계 | `newsletter_id`, `subscription_attempt_id` | 공개 정보 있음: `newsletter_name` | 시도→페이지 표시. 팝업·내부 이동 제외 |
| E22 / P1 | `newsletter_subscribe_page_closed` | 화면 종료 후 앱으로 복귀 / 구독 종료 경계 | `newsletter_id`, `subscription_attempt_id` | 공개 정보 있음: `newsletter_name` | 페이지 복귀 관찰. 강제 종료·완료 추정 제외 |
| E24 / P0 | `home_action_selected` | 홈 안내·다른 날짜·재시도의 실제 선택 / 해당 처리 경계 | `state`, `reason`, `action`, `date_relation` | 없음 | M09·M12의 날짜 변경. 이후 성공을 뜻하지 않음 |
| E25 / P0 | `operation_failed` | 현재 사용자 작업의 비취소 실패 / 해당 결과 소유자 | `operation`, `error_category` | 아래 작업별 연결 필드 | 병목의 오류 진단. 인증 실패는 E05만 기록 |
| E27 / P0 | `bookmark_changed` | 북마크 작업 성공·실제 상태 변경 / ArticleDetailViewModel의 성공 경계 | `article_view_id`, `item_id`, `newsletter_id`, `action` | 공개 정보 있음: `newsletter_name` | M12·M17. added/removed 분리, 버튼 누름·토스트 제외 |
| E28 / P0 | `highlight_applied` | 하이라이트 적용 저장 성공 / ArticleDetailViewModel의 addHighlight 성공 경계 | `article_view_id`, `item_id`, `newsletter_id` | 공개 정보 있음: `newsletter_name` | M12·M17. 선택·스타일 편집·삭제와 구분 |

screen_view·login·sign_up·select_content는 SDK 권장 이름을 사용한다. select_content는 content_type·item_id 조합이다.
설치된 Firebase iOS SDK 12.19.1 헤더와 대조했다. first_open·session_start·user_engagement는 직접 재전송하지 않는다.
[Firebase 상수](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Constants),
[Firebase 이벤트](https://firebase.google.com/docs/analytics/ios/events?platform=ios)

## 범위가 있는 연결 ID: 6종

| 필드 | 수명·생성 | 필요한 이유 / 전달 범위 |
|---|---|---|
| `auth_flow_id` | 온보딩 또는 로그인 진입부터 메인 진입까지 하나. 재진입은 새 값 | M08의 분기·24시간 흐름. Auth와 최초 메인에만 전달 |
| `auth_attempt_id` | 실제 Apple·Kakao 인증 시도마다 새 값 | E04와 E05 또는 E06의 일대일 대응. Auth 안에서만 사용 |
| `list_view_id` | 날짜·필터·검색·실제 새 로드·계정 변경마다 새 값. 같은 계정의 캐시/결과 복귀는 유지 | M04의 원래 목록과 선택·본문 연결. 검색 요청에도 같은 키 사용 |
| `article_view_id` | 상세 navigation 항목마다 생성. 재로드/뒤로 복귀는 유지 | M05의 본문 표시→열람. 닫고 새로 열거나 계정 변경 시 새 값 |
| `newsletter_view_id` | 뉴스레터 상세 navigation 방문마다 생성. 계정 변경은 새 값 | M06의 상세 표시→구독 시작. 상세와 해당 시작 이벤트에만 사용 |
| `subscription_attempt_id` | 외부 구독 진입마다 생성 | 시도→페이지 표시·복귀·실패. 해당 구독 화면에서만 사용 |

모두 String(UUID), 소문자 36자다. 전체 앱의 전역 방문·작업 수명 관리자는 만들지 않는다.
list_view_id를 검색 요청·결과·목록·선택에 재사용하므로 별도 검색/로드 ID가 필요 없다.
M04는 세션당 전환 여부이므로 item_id·list_view_id·순서·article_view_id로 충분하며 선택 UUID를 추가하지 않는다.

## 나머지 필드의 타입과 허용값

| 필드 | 타입 | 허용값·현재 용도 |
|---|---|---|
| `screen_name` | String(enum) | onboarding, login, signup, home, explore, search, subscriptions, bookmarks, newsletter_detail, article_detail, subscribe_web, mypage |
| `step_key` | String(enum) | 온보딩 intro_1/intro_2/intro_3. 가입 profile/terms/account_complete/recommend_intro/industry/interests/curation |
| `next_screen` | String(enum) | login, signup. 온보딩에서 고른 다음 진입 |
| `method` | String(enum) | apple, kakao. 가입까지 원래 방식을 전달하고 토큰에서 추출하지 않음 |
| `outcome` | String(enum) | E05: signup_required, failed, cancelled. E09: completed, skipped. 기존 회원 성공은 E06 |
| `content_type` | String(enum) | article, newsletter. item_id의 이름 공간 구분 |
| `item_id`, `newsletter_id` | String(내부 ID) | 검증된 1~100자. 정수 ID는 양수. 기사 brandId는 newsletter_id이며 기사 ID와 혼동하지 않음 |
| `newsletter_name` | String(공개 카탈로그 표시명), 선택 | 해당 newsletter_id의 서버 공개 브랜드명만, 1~100자. 길이 초과·누락은 키 생략. 그룹 키는 ID이며 원문 사용자 이름은 금지 |
| `list_id` | String(enum) | home_articles, newsletter_articles, explore_recommended, explore_all, search_newsletters, subscribed_newsletters, paused_newsletters, bookmarked_articles, signup_curation |
| `surface` | String(enum) | home, explore, search, subscriptions, bookmarks, signup_curation, newsletter_articles |
| `state` | String(enum) | ready, guest, empty, failed. 상태 묶음 비교 |
| `reason` | String(enum) | none, authentication_required, no_subscriptions, no_articles_on_date, no_results, request_failed. 원인 구분 |
| `date_relation` | String(enum) | today, past, future. 홈이 표시하거나 행동을 시작한 원래 날짜 기준 |
| `article_kind` | String(enum) | current, past. 실제 isPast 진입 값이며 발행일로 추정하지 않음 |
| `engagement_rule` | String(enum) | 초기 visible_30s_v1. 열람 기준 버전이며 payload 스키마 버전과 구분 |
| `active_visible_ms` | Int(밀리초) | 기준 도달 당시 활성 가시 시간, 현재 30000 이상. 전체 열람 시간은 아님 |
| `subscription_status` | String(enum) | initial, check, confirmed, paused, unknown. 가입 추천에는 상태가 없으므로 unknown |
| `query_source` | String(enum) | typed, popular_keyword. 검색어 원문·해시 미수집 |
| `result_bucket` | String(enum) | zero, non_zero. M10에 필요한 결과 없음 여부만 수집 |
| `action` | String(enum) | E24: signup, login, explore_recommended, explore_by_day, change_date, retry. E27: added, removed. 이벤트별 타입 분리 |
| `operation` | String(enum) | signup_submit, profile_setup, home_load, content_load, newsletter_search, newsletter_detail_load, article_load, article_render, subscribe_page_load, bookmark_update, highlight_save |
| `error_category` | String(enum) | network, server, authentication, validation, sdk, rendering, unknown. 원문 오류·응답 body 미전송 |

전송은 String·Int만 사용한다. UUID·enum은 변환하고 적용되지 않는 키는 생략한다. Bool·Date·URL·객체·null·빈 문자열을 넣지 않는다.
새 필드는 사용하는 지표·진단과 타입·허용값을 먼저 등록한다. 상세 결과 건수 구간 등 소비자가 없는 값은 미리 추가하지 않는다.

### 조합·소유권

- state/reason 조합은 ready/none, guest/authentication_required, empty/no_subscriptions,
  empty/no_articles_on_date, empty/no_results, failed/request_failed만 허용한다.
- no_articles_on_date는 Home 전용이다. 빈 중지 목록은 no_results + paused_newsletters이며 구독 없음으로 일반화하지 않는다.
- E01의 step_key는 온보딩·가입 화면에서만 사용한다. 실제 단계 전환 때 기록하며 별도 단계 이벤트를 보내지 않는다.
- E05 실패에는 error_category가 필요하다. cancelled에는 오류 분류·E25를 추가하지 않는다.
  한 인증 시도는 E05 또는 E06 중 하나로만 끝난다. signup_required는 실패가 아니다.
- E13 ready는 실제 정상 목록 표시다. ViewModel 생성·API 성공·lazy row 생성만으로 기록하지 않는다.
  연속 노출 중 같은 목록·상태는 한 번, 실제 복귀·scene 활성화로 다시 보이면 재노출을 기록한다.
  로컬 표시 제어에 필요한 상태는 두되 전역 화면 UUID를 전송하지 않는다.
- E15는 채택된 검색 응답, E13은 실제 화면 노출이다. 서로 다른 사실이며 둘을 더해 검색 수로 세지 않는다.
- E14는 실제 검색 실행이다. 성공·무결과·실패·취소로 끝나도 M12 검색 이용에 포함하고, M10의 성공 분모는 E15만 쓴다.
- 기사 목록 선택의 item_id·list_view_id는 E16~E18과 일치한다. 뉴스레터 선택은 E19의 newsletter_id·list_view_id와 일치한다.
- E12의 content_type=newsletter일 때 newsletter_id=item_id다. 권장 item_id는 유지하고, 뉴스레터별 교차 이벤트 보고서에 동일 newsletter_id를 사용한다.
  공개 이름은 표시 보조값으로만 수집한다. 같은 이름의 다른 ID를 합치거나 이름 변경을 새 뉴스레터로 세지 않는다.
  newsletter_id가 없는 이벤트에는 newsletter_name도 넣지 않는다. article 선택 E12는 이 라벨을 생략하며 본문 응답 이후 E17/E18에서 제공한다.
- E20의 entry_point는 newsletter_detail 또는 signup_curation이다. 가입 추천을 M06 상세 분모에 넣지 않는다.
  E21·E22의 newsletter_id·subscription_attempt_id·entry_point는 E20과 같다.
- WebView 로딩 false는 성공 근거가 아니다. 현재 루트 WebView 성공 callback을 확인하고 팝업과 구분한다.
- change_date는 실제 다른 날짜를 고른 경우다. home_action_selected는 선택만 기록하며 후속 화면에 별도 회복 ID를 전파하지 않는다.
- 업무 결과는 현재 요청·인증 문맥을 검사한 후 기록한다. 취소·대체된 응답·사용자 변경으로 무효화된 결과는 미기록이다.
- E27은 use case 성공 후 실제 isBookmarked 변경값으로 added/removed를 정한다. 호출 함수의 반환이나 토스트 표시만으로 성공을 추정하지 않는다.
- E28은 addHighlight 저장 성공을 뜻한다. 신규 고유 문장 수가 아니며, 선택 문장·해시·색상·기사 제목·하이라이트 ID를 전송하지 않는다.
  이전 상태 복원·목록 조회·색상 변경·삭제는 적용으로 세지 않는다. 저장 뒤 목록 재조회 성공과도 구분한다.

### E25의 필요한 연결 필드

| operation | 조건부 필수 | 비고 |
|---|---|---|
| signup_submit, profile_setup | `auth_flow_id` | 같은 가입 흐름의 실패 구분. 별도 저장 작업 UUID 없음 |
| home_load, content_load, newsletter_search | `list_id`, `list_view_id` | 현재 로드·검색 문맥. 재시도는 새 목록 문맥이며 이전 시도 연결 분석은 초기 범위 밖 |
| newsletter_detail_load | `newsletter_id`, `newsletter_view_id` | 해당 상세의 실패. 표시 성공을 추정하지 않음 |
| article_load | `article_view_id`, `item_id`, `article_kind` | 같은 기사 진입에서 API 실패 진단 |
| article_render | `article_view_id`, `item_id`, `article_kind`, `newsletter_id` | 메타데이터 이후 본문 표시 실패 진단 |
| subscribe_page_load | `newsletter_id`, `subscription_attempt_id` | 루트 구독 페이지만 해당. 팝업 오류와 혼합하지 않음 |
| bookmark_update, highlight_save | `article_view_id`, `item_id`, `newsletter_id` | 실패는 E27/E28 성공으로 세지 않음. 선택 원문·오류 body 미전송 |

원래 작업의 화면·진입 문맥을 유지하고 관계없는 ID를 채우지 않는다. 실패 원문·URL·본문은 보내지 않는다.

## 키 수·보고서·확장

최대는 E18의 공통 5 + 기사·열람 6 + 목록 출처 1 + 공개 표시명 1 = 13개다. 앱이 설정한 SDK default 키의 합집합까지 25개 이내인지 검증한다.
현재 허용 필드만 변환한다. SDK 전역 default에는 정적 환경·빌드만 두고 흐름 ID·인증·화면 상태는 영구 저장하지 않는다.
[SDK 타입·한도](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics),
[수집 한도](https://support.google.com/analytics/answer/9267744?hl=en)

GA4에서는 기본 화면·사용자·세션·버전 차원을 먼저 사용한다. custom dimension은 event_version, measurement_env,
auth_state, entry_point, step_key, outcome, list_id, surface, state, reason, date_relation, result_bucket 등 실제 보고서에 필요한 것만 등록한다.
UUID 연결 ID·개별 기사 item_id는 초기 custom dimension에 등록하지 않는다. 원시 연결에 사용한다.
newsletter_id는 이번 뉴스레터별 보고서의 실제 분해 기준이므로 값 수·기존 할당량을 확인해 이벤트 범위 custom dimension으로 등록한다.
newsletter_name은 공개 표시가 필요한 보고서에 등록한다. ID 기준 수치와 이름 변경·동명이름의 분리 오류를 검증한다.
값이 많아 GA4 집계가 축약되면 원시 데이터와 최신 공개 카탈로그 매핑을 사용하며, 이름만으로 합치지 않는다.
active_visible_ms는 필요할 때 custom metric으로 등록하며 고유값이 많은 dimension으로 만들지 않는다.
[GA4 맞춤 정의](https://support.google.com/analytics/answer/14240153?hl=en)

신규 이벤트·필드는 지표/진단 사용처, 발생 소유자, 타입·허용값, 수명·중복, 도입 빌드, 검증 예시를 먼저 적는다.
동일 사실을 기존 이벤트의 선택 필드로 설명할 수 있으면 새 이벤트를 만들지 않는다.
실제 구독 완료·정확한 안내 후 회복·상세 재시도 분석은 필요와 근거를 확인한 뒤 별도 계약을 작성한다.

## 초기 초안에서 줄인 항목

| 초안 항목 | 이번 결정 |
|---|---|
| E02·E08 단계 노출 | E01 screen_view + step_key로 통합 |
| E11 정상 목록 노출 | E13 ready로 통합 |
| E14 검색 시작 | M10만 있던 최소안에서는 제외했으나, 이번 M12의 실제 검색 이용 질문이 생겨 복원. 별도 검색 UUID는 여전히 없음 |
| E23 서버 상태 관찰 | E19에 이미 상태가 있음. 현재 지표 소비자가 없어 제외 |
| E26 신규 구독 완료 | 서버 근거 미확정. 실행 가능한 이벤트 계약에 포함하지 않고 Q-03에서 재설계 |
| 전역 event_id·screen_visit_id | 현재 지표의 단위·발생 제어로 중복 방지. 초기 SDK payload에서 제외 |
| 검색·로드·선택·저장·회복의 별도 ID | 필요한 6종으로 축소. 미리 ID 전파·저장소를 구축하지 않음 |
| 모든 검색 결과 건수 구간·복귀 방식·고정 출처 필드 | 현재 의사결정에 필요한 zero/non_zero·복귀 사실·상세 상태만 유지 |

위 제외 E ID는 초안 정리 이력이며 구현할 enum case가 아니다. 미배포 초안 정리 과정에서 event_version 1을 유지했고, 승인된 로컬 구현도 v1을 사용한다.
SDK 타입·권장 필드의 정확성은 유지하면서 수집 범위를 줄였다.
화면·기능·뉴스레터 이용 분석 요구로 E14·E27·E28과 선택적 공개 이름을 추가했다. 공통 5개·UUID 6종은 유지하며 현재 필드 정의는 34개다.
