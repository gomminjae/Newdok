# Code intelligence

Newdok은 Tuist의 타깃 그래프를 기준으로 유지하면서 코드 탐색 도구를 하나씩 비교한다.
앱 타깃·의존성·테스트 정책은 변경하지 않는다.

## 구성

| 도구 | 버전 | 기본 상태 | 역할 |
|---|---|---|---|
| CodeGraph (`colbymchenry/codegraph`) | 1.6.2 | 활성 | 로컬 호출·타입·변경 영향 탐색 |
| Serena (`serena-agent`) | 2.1.0 | 비활성 | SourceKit-LSP 정의·참조 탐색, 읽기 전용 |
| codebase-memory-mcp | 0.12.1 | 비활성 | 별도 그래프 인덱스와 비교, analysis 도구만 노출 |
| uv | 0.13.5 | mise 관리 | Serena의 격리된 Python 3.13 실행 환경 |

OpenCode V2 프로젝트 설정은 `opencode.json`의 `mcp.servers`에 있다.
전역 에이전트 설정·자동 승인·hook은 추가하지 않는다.
각 도구의 `install`/`setup` 마법사는 실행하지 않는다. 이 명령들은 다른 클라이언트의 설정이나 지침을 바꿀 수 있다.

## 설치 및 검증

저장소 루트에서 실행한다. npm backend 설치에는 Node.js/npm이 필요하다.

```sh
mise trust
mise install --yes
mise exec -- codegraph init --yes
python3 scripts/check-codegraph.py
opencode mcp list
```

`mise trust`는 이 저장소의 mise 설정을 검토한 뒤 실행한다.
`--yes`는 필요한 mise plugin 설치를 허용하며 전역 MCP 등록을 뜻하지 않는다.
Serena는 첫 실행 때 uv가 버전 고정된 패키지와 필요한 Python 환경을 준비한다.
npm이 codebase-memory의 postinstall을 막아도 첫 CLI 실행 때 공식 shim이 바이너리를 다운로드하고 체크섬을 검증한다.

기존 인덱스를 다시 만들거나 직접 조회하려면:

```sh
mise exec -- codegraph index
python3 scripts/check-codegraph.py
mise exec -- codegraph status
mise exec -- codegraph query SearchViewModel --json
mise exec -- codegraph explore "SearchViewModel SearchDIContainer SearchRepositoryImpl"
```

MCP가 연결된 동안 CodeGraph는 변경을 자동 반영한다. 인덱스가 오래됐다는 표시가 있으면 원문을 확인한다.
OpenCode는 설정 저장 후 자동으로 반영하며, 필요하면 `/reload`를 사용한다.

## 인덱스 범위와 회귀 검사

- `codegraph.json`: 현재 App·Core·Feature의 명시적 포함 경로와 생성물·민감 경로 제외.
- `.cbmignore`: codebase-memory 비교용 제외 경로.
- `.serena/project.yml`: Swift LSP만 사용하며 편집 도구를 막고 생성물·민감 경로를 제외.
- `.codegraph/`, `.serena/`의 실행 데이터, `.codebase-memory/`는 Git에서 제외한다.
- 테스트·Testing·Example 소스는 포함한다. 코드 관계 탐색에 필요한 Tuist manifest/helper도 유지한다.

CodeGraph 1.6.2는 이 체크아웃의 Git ignored-directory 목록에 있는 루트 `Sources/`를
모든 깊이의 `Sources/`에 적용해 앱 소스를 누락했다. `include`로 현재 모듈을 명시해 방지한다.
`exclude`는 포함 경로보다 우선하므로 Derived·설정·키 경로는 다시 포함되지 않는다.

와일드카드로 전체 `Modules/**/Sources/`를 포함하면 Git의 `MyPage`와 실제 폴더의
`Mypage`가 별개 경로로 중복 인덱싱됐다. 따라서 Git 경로의 대소문자를 사용한다.
모듈 추가 시 `codegraph.json`의 포함 경로를 갱신한다.

`scripts/check-codegraph.py`는 현재 Modules의 자체 Swift 파일이 모두 인덱싱됐는지,
같은 물리 파일이 여러 경로로 중복됐는지, 제외 경로가 들어왔는지 확인한다.
소스 본문을 출력하거나 인덱스를 수정하지 않는다. 호출 관계의 의미적 정확성을 보증하는 검사는 아니다.

## 비교 도구로 전환

`opencode.json`에서 CodeGraph를 `disabled: true`로 바꾸고 비교할 도구 하나만
`disabled: false`로 바꾼다. 동시에 여러 도구를 켠 결과를 속도·토큰 비교에 섞지 않는다.

### Serena

`scripts/serena-mcp.sh`는 `xcrun`이 선택한 Xcode의 SourceKit-LSP를 우선한다.
Swiftly의 별도 Swift 툴체인과 iOS 빌드 인덱스를 혼용하지 않는다.
Serena의 사용자 설정·로그는 저장소의 `.serena/home/`에 격리한다.

다른 체크아웃/머신에서 사용하거나 DerivedData가 바뀌었다면 먼저 BSP를 다시 연결한다.

```sh
xcode-build-server config -workspace Newdok.xcworkspace -scheme Newdok
```

`buildServer.json`은 머신별 절대 경로를 담는다. 기존 QA/B 설정이 남아 있다면 위 명령으로 재생성한다.
로컬 경로 변경은 공유 설정 커밋에 포함하지 않는다.
컴파일 옵션·참조 인덱스가 오래됐으면 Xcode에서 해당 타깃을 빌드한다.
등록하지 않은 테스트/Example 타깃의 참조까지 완전하다고 가정하지 않는다.

### codebase-memory

최초 비교 인덱스는 CLI로 만든다. MCP에는 읽기 중심의 `analysis` profile만 연결한다.

```sh
mise exec -- codebase-memory-mcp cli index_repository --repo-path "$PWD" --name Newdok --mode fast
mise exec -- codebase-memory-mcp cli search_graph --project Newdok --name-pattern '^SearchViewModel$' --format json
```

CLI만 사용한 인덱스는 파일 수정 후 같은 indexing 명령으로 갱신한다.
`fast`는 전체 문서·의미 검색 비교를 위한 설정이 아니라 소스 관계를 빠르게 시험하는 설정이다.
초기 실행에서 Swift 11개 파일의 일부 구문을 파싱하지 못했다는 `parse_partial` 신호가 있었다.
`status: indexed`만 보고 분석이 완전하다고 판단하지 않는다.

## 비교 기준

1. Search의 ViewModel → UseCase → Repository → Network 연결.
2. 실제 DI 구현체와 테스트 mock의 구분.
3. 다른 모듈의 같은 이름(`execute`, `request`)을 잘못 연결하는지.
4. 파일 수정 후 결과의 갱신과 누락·오래된 인덱스 표시.
5. 동일 질문의 정확도·응답 시간·메모리·반환 컨텍스트 크기.

그래프 결과만으로 미사용 코드를 삭제하거나 테스트 범위를 줄이지 않는다.
모듈 의존성의 기준은 `Workspace.swift`, `Project.swift`, `ProjectHelper.swift`와 Tuist다.
타깃 그래프를 별도로 보려면:

```sh
mkdir -p build/code-intelligence
mise exec -- tuist graph --format dot --skip-external-dependencies --no-open --output-path build/code-intelligence
```

## 개인정보와 보안

CodeGraph telemetry는 mise와 MCP 환경에서 꺼둔다.
로컬 인덱싱은 외부 전송이 전혀 없다는 뜻이 아니다. MCP가 반환한 코드가 현재 모델 제공자에게 전달될 수 있다.
제외 경로는 도구의 입력 범위를 줄이는 설정이지 OS 접근 제어나 비밀 탐지기의 대체재는 아니다.
인덱스·로그에도 코드가 들어갈 수 있으므로 커밋하거나 외부로 공유하지 않는다.
