#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir/.."

# Match SourceKit-LSP to the Xcode SDK/build index, not an unrelated Swiftly toolchain.
toolchain_bin=$(dirname -- "$(xcrun --find sourcekit-lsp)")
export PATH="$toolchain_bin:$PATH"
export SERENA_HOME="$PWD/.serena/home"

exec mise exec -- uvx --python 3.13 --from serena-agent==2.1.0 serena \
    start-mcp-server --context ide --project "$PWD" \
    --enable-web-dashboard false --open-web-dashboard false "$@"
