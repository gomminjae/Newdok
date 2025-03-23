#!/bin/bash

# 현재 디렉토리 이름을 모듈 이름으로 사용
MODULE_NAME=$(basename "$PWD")
BUNDLE_PREFIX="com.newdok"
PROJECT_FILE="Project.swift"

# 디렉토리 생성
mkdir -p Sources Resources Tests

# 기본 Swift 파일 추가
touch Sources/"${MODULE_NAME}Main.swift"
touch Tests/"${MODULE_NAME}Tests.swift"

# Project.swift 생성
if [ -f "$PROJECT_FILE" ]; then
  echo "🟡 $MODULE_NAME: Project.swift already exists. Skipping."
else
  echo "🛠️ Generating Project.swift for module '$MODULE_NAME'..."
  cat <<EOF > "$PROJECT_FILE"
import ProjectDescription

let project = Project(
    name: "$MODULE_NAME",
    targets: [
        .target(
            name: "$MODULE_NAME",
            destinations: [.iOS],
            product: .staticFramework,
            bundleId: "$BUNDLE_PREFIX.$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')",
            sources: ["Sources/**"],
            resources: ["Resources/**"]
        ),
        .testTarget(
            name: "${MODULE_NAME}Tests",
            dependencies: ["$MODULE_NAME"],
            sources: ["Tests/**"]
        )
    ]
)
EOF
  echo "✅ Project.swift created for $MODULE_NAME"
fi

