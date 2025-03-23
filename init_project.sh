#!/bin/bash

# 현재 디렉토리 기준
MODULE_NAME=$(basename "$PWD")
BUNDLE_PREFIX="com.newdok"
ORG_NAME="Newdok"
PROJECT_FILE="Project.swift"

# 필수 디렉토리 생성
mkdir -p Sources Resources Tests
touch Sources/"${MODULE_NAME}Main.swift"
touch Tests/"${MODULE_NAME}Tests.swift"

# 덮어쓰기 생성
echo "🛠️ Generating Project.swift for module '$MODULE_NAME'..."

cat <<EOF > "$PROJECT_FILE"
import ProjectDescription

let project = Project(
    name: "$MODULE_NAME",
    organizationName: "$ORG_NAME",
    targets: [
        .target(
            name: "$MODULE_NAME",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "$BUNDLE_PREFIX.$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]')",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: ["Resources/**"]
        ),
        .target(
            name: "${MODULE_NAME}Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "$BUNDLE_PREFIX.$(echo "$MODULE_NAME" | tr '[:upper:]' '[:lower:]').tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "$MODULE_NAME")
            ]
        )
    ]
)
EOF

echo "✅ Project.swift created and overwritten in '$MODULE_NAME'"

