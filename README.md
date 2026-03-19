# Newdok

> 뉴스레터를 한곳에서. 구독하고, 탐색하고, 저장하세요.

[![Platform](https://img.shields.io/badge/Platform-iOS_17.0+-orange)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-FA7343?logo=swift&logoColor=white)](https://swift.org)
[![Architecture](https://img.shields.io/badge/Architecture-Clean_+_MVVM-blue)]()
[![License](https://img.shields.io/badge/License-MIT-green)]()

Newdok은 다양한 뉴스레터를 한곳에서 구독하고, 날짜별로 아티클을 탐색하며, 관심 콘텐츠를 북마크할 수 있는 iOS 앱입니다.

## Features

- **캘린더 기반 아티클 탐색** — 날짜별로 뉴스레터 아티클을 확인하고 월 단위로 탐색
- **뉴스레터 구독 관리** — 관심 분야별 뉴스레터 구독 및 해지
- **카테고리별 탐색** — 산업/요일/추천 기준으로 뉴스레터 브라우징
- **아티클 북마크** — 관심 아티클 저장 및 관심사별 필터링
- **하이라이트** — 아티클 내 중요 문장 하이라이트 및 커스텀 팔레트
- **검색** — 아티클 및 뉴스레터 통합 검색
- **게스트 모드** — 비로그인 상태에서도 기본 탐색 가능

## Tech Stack

| 영역 | 기술 |
|---|---|
| **UI** | SwiftUI, iOS 17.0+ |
| **아키텍처** | Clean Architecture + MVVM |
| **모듈화** | [Tuist](https://tuist.io) |
| **네트워크** | [Moya](https://github.com/Moya/Moya) / Alamofire |
| **DI** | [Swinject](https://github.com/Swinject/Swinject) |
| **이미지** | [Kingfisher](https://github.com/onevcat/Kingfisher), [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) |
| **상태 관리** | Combine, [TCA](https://github.com/pointfreeco/swift-composable-architecture) |
| **애널리틱스** | Firebase Analytics, Crashlytics |
| **코드 품질** | SwiftLint |

## Architecture

```
Modules/
├── App                  # 앱 엔트리포인트
├── AppCoordinator       # 네비게이션 & DI 컨테이너
├── Core                 # 네트워크 레이어 (Moya)
├── Data                 # Repository 구현체, DTO
├── Domain               # Entity, UseCase, Repository Protocol
├── DesignSystem         # 공용 UI 컴포넌트, 컬러, 폰트
├── Shared               # Router, 유틸리티
└── Features/
    ├── Auth             # 로그인, 회원가입, 온보딩
    ├── Home             # 캘린더 기반 아티클 피드
    ├── Explore          # 뉴스레터 탐색
    ├── Subscribe        # 구독 관리
    ├── Bookmark         # 북마크
    ├── Detail           # 아티클 & 브랜드 상세
    ├── Search           # 검색
    ├── MyPage           # 프로필 & 설정
    ├── Launch           # 스플래시
    └── Survey           # 온보딩 설문
```

각 Feature 모듈은 독립적인 static framework로 컴파일되며, **Domain** → **Data** → **Presentation** 방향의 의존성을 유지합니다.

## Getting Started

### Prerequisites

- Xcode 16.0+
- [Tuist](https://tuist.io) 4.x
- iOS 17.0+ 시뮬레이터 또는 디바이스

### Build

```bash
# 1. 저장소 클론
git clone https://github.com/gomminjae/Newdok.git
cd Newdok

# 2. Tuist로 프로젝트 생성
tuist install
tuist generate

# 3. Xcode에서 빌드 & 실행
open Newdok.xcworkspace
```

## Project Structure

```
Newdok/
├── Workspace.swift          # Tuist 워크스페이스 설정
├── Tuist/
│   └── Package.swift        # 외부 의존성 정의
├── Modules/                 # 모듈별 소스코드
├── .swiftlint.yml           # SwiftLint 설정
└── .github/workflows/       # CI 워크플로우
```

## License

This project is licensed under the MIT License.
