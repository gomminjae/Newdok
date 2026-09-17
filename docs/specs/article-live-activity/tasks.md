# Tasks: 아티클 Live Activity

> plan.md를 순서 있는 작업으로 분해. 각 항목은 독립적으로 커밋 가능해야 이상적.

- [x] Shared에 ActivityAttributes와 ContentState를 추가한다.
- [x] Detail Domain publisher 프로토콜과 ViewModel DI를 추가한다.
- [x] App에 ActivityKit publisher와 로그아웃 종료 처리를 추가한다.
- [x] Widget Extension에 Lock Screen·Dynamic Island ActivityConfiguration을 추가한다.
- [x] 뉴스레터 이미지와 `읽는 중` 상태를 Live Activity attributes·UI에 추가한다.
- [x] compact는 브랜드 이미지·브랜드명 한 줄 말줄임으로 표시하고, expanded·Lock Screen은 브랜드명과 제목 두 줄을 사용한다.
- [x] 현재 아티클 화면에서만 활동을 시작하고 화면을 벗어나면 해당 활동을 종료한다.
- [x] 앱 URL 라우팅과 아티클 상세 이동을 연결한다.
- [x] Detail ViewModel 테스트를 추가하고 관련 모듈 테스트를 실행한다.
- [x] `mise exec -- tuist generate --no-open`으로 프로젝트를 재생성한다.
- [ ] 라우팅 기반 시작·종료와 비동기 취소 처리를 검증한다.
- [x] API→웹뷰 로딩 연결 및 중복 fetch 방지를 검증한다.
- [ ] 이미지 payload 크기 제한을 검증한다.
- [x] 전체 테스트와 Newdok 시뮬레이터 빌드를 다시 실행한다.
- [ ] 실제 Dynamic Island 표시를 확인한다.

## 검증 상태 (2026-09-17)

- Newdok 스킴 빌드, 전체 테스트, 중복 테스트 정리 후 Detail 테스트 통과.
- compact를 브랜드 이미지·브랜드명 말줄임으로 변경한 뒤 Newdok 앱·위젯 빌드 통과. 이번 UI 변경에 별도 테스트 코드를 추가하지 않았다.
- 임시 시뮬레이터 검증 앱에서 생성·재사용·종료·종료 후 시작 차단·썸네일 크기 검사를 통과했다.
- 시스템 API의 활동 생성 성공과 실제 Dynamic Island 렌더링은 구분한다. 배경 전환 후 캡처에서는 아직 표시를 확인하지 못했으므로 기능 완료로 표시하지 않는다.
