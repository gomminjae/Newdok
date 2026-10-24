#!/usr/bin/env python3
"""Check source coverage and exclusions without printing source or changing the index."""

import json
from collections import defaultdict
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parent.parent
SKIP_DIRECTORIES = {
    "Derived", "DerivedData", "build", ".build", ".swiftpm", ".omc", ".claude",
    ".serena", ".codegraph", ".codebase-memory", "private_keys", "Configurations",
}
SECRET_SUFFIXES = {".xcconfig", ".p8", ".p12", ".cer", ".mobileprovision"}


def identity(path):
    # Git and the filesystem disagree on MyPage/Mypage casing in this checkout.
    # Compare physical files so duplicate spellings cannot inflate coverage.
    stat = path.stat()
    return stat.st_dev, stat.st_ino


def excluded(path):
    return (
        bool(SKIP_DIRECTORIES.intersection(path.parts))
        or any(part.endswith((".xcodeproj", ".xcworkspace")) for part in path.parts)
        or path.is_relative_to(Path("Modules/App/Configs"))
        or path.suffix in SECRET_SUFFIXES
        or any(part.startswith(".env") for part in path.parts)
    )


def main():
    result = subprocess.run(
        ["mise", "exec", "--", "codegraph", "files", "--json"],
        cwd=ROOT, capture_output=True, text=True, check=True,
    )
    files = json.loads(result.stdout)
    indexed = defaultdict(list)
    errors = []
    for file in files:
        path = Path(file["path"])
        full_path = ROOT / path
        if not full_path.resolve().is_relative_to(ROOT):
            errors.append("Index contains a path outside the repository")
            continue
        if excluded(path):
            errors.append(f"Excluded path indexed: {path}")
        if not full_path.is_file():
            errors.append(f"Stale index entry: {path}")
            continue
        indexed[identity(full_path)].append(str(path))

    expected = {
        identity(path): str(path.relative_to(ROOT))
        for path in (ROOT / "Modules").rglob("*.swift")
        if not excluded(path.relative_to(ROOT))
    }
    for key, path in expected.items():
        if key not in indexed:
            errors.append(f"Swift file missing: {path}")
    for paths in indexed.values():
        if len(paths) > 1:
            errors.append("Duplicate physical file: " + ", ".join(paths))

    if errors:
        raise SystemExit("\n".join(errors))
    print(f"CodeGraph coverage OK: {len(expected)} first-party Swift files; "
          f"{len(files)} indexed files; no excluded paths or duplicates.")


if __name__ == "__main__":
    main()
