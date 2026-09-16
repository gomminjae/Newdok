# Tasks: 잠금화면 뉴스레터 요약 위젯

> plan.md를 순서 있는 작업으로 분해한다. 구현 진행 상황과 검증 결과를 함께 기록한다.

- [x] `spec.md` 수용 조건과 표시 범위 승인
- [x] `Shared`에 `WidgetHomeSummary`와 App Group snapshot 저장소 추가
- [x] `HomeDomain`에 snapshot publisher 프로토콜 추가
- [x] `HomeViewModel`에 publisher 주입 및 오늘 load/read/auth reset 갱신 연결
- [x] `HomeTests`에 publisher 호출·날짜 경계·로그아웃 초기화 테스트 추가
- [x] `Modules/NewdokWidget` Widget Extension manifest, entitlements, bundle 추가
- [x] 원형·직사각형 accessory widget과 자정 timeline 구현
- [x] App target App Group entitlement 및 Widget target dependency 등록
- [x] `AppContainer`에서 publisher를 조립하고 HomeBuilder에 전달
- [x] `NewdokApp`의 `newdok://home` deep link 처리 추가
- [x] `mise exec -- tuist install` 및 `mise exec -- tuist generate --no-open`
- [x] 해당 모듈 테스트와 Debug 빌드 실행
- [ ] 실제 기기 Lock Screen에서 0/1/12개, 읽음 처리, 자정 경계 확인
- [ ] 수용 조건 검증 후 `spec.md` 상태를 `done`으로 변경
