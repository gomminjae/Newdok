#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir/.."

"$script_dir/validate-test-harness.sh"
mise exec -- tuist install
exec mise exec -- tuist test --platform ios "$@"
