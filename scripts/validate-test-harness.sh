#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

find "$script_dir/../Modules" -type d -name Tests -print | while IFS= read -r tests_dir; do
    module_dir=${tests_dir%/Tests}
    if [ ! -x "$module_dir/test.sh" ]; then
        echo "error: executable test.sh missing: $module_dir/test.sh" >&2
        exit 1
    fi
done
