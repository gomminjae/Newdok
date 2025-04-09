#!/bin/bash

# 변경 전/후 이름
OLD_NAME="Network"
NEW_NAME="Core"

echo "🔍 $OLD_NAME → $NEW_NAME 전체 변경 시작"

# 1. 디렉토리명 변경 (예: Modules/Network → Modules/AppNetwork)
find . -type d -name "$OLD_NAME" | while read dir; do
  newdir="$(echo "$dir" | sed "s/$OLD_NAME/$NEW_NAME/g")"
  echo "📁 Rename directory: $dir → $newdir"
  mv "$dir" "$newdir"
done

# 2. 파일 내 문자열 일괄 치환
echo "📝 소스 코드 내 import 등 치환 중..."
grep -rl "$OLD_NAME" . \
  --exclude-dir=".git" \
  --exclude="*.xcworkspace*" \
  --exclude-dir="DerivedData" \
  | xargs sed -i '' "s/\b$OLD_NAME\b/$NEW_NAME/g"

# 3. DerivedData 정리 권장
echo "🧹 DerivedData는 수동 삭제 권장: rm -rf ~/Library/Developer/Xcode/DerivedData"

echo "✅ 모듈 리네이밍 완료"

