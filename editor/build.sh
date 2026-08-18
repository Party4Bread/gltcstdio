#!/usr/bin/env bash
# Build the editor: the wasm module the filters run in, then the page's
# TypeScript.
#
#   ./editor/build.sh && python -m http.server -d editor 8000
#
# Needs the wasm target and wasm-bindgen's CLI at the version the crate pins:
#   rustup target add wasm32-unknown-unknown
#   cargo install wasm-bindgen-cli --version 0.2.127
#
# The TypeScript step needs pnpm; pass --skip-ts to build only the wasm, which
# leaves whatever is already in editor/dist alone.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"

cargo build --manifest-path "$root/rust/Cargo.toml" \
    -p gltcstdio-wasm --target wasm32-unknown-unknown --release

# The .d.ts is what types the module boundary for the page, so it is generated
# rather than skipped.
wasm-bindgen --target web \
    --out-dir "$here/pkg" \
    "$root/rust/target/wasm32-unknown-unknown/release/gltcstdio_wasm.wasm"

printf 'built %s\n' "$(du -h "$here/pkg/gltcstdio_wasm_bg.wasm" | cut -f1)"

if [[ "${1:-}" != "--skip-ts" ]]; then
    if ! command -v pnpm >/dev/null; then
        echo "pnpm not found; skipping the TypeScript build" >&2
        exit 0
    fi
    [[ -d "$here/node_modules" ]] || pnpm --dir "$here" install --silent
    pnpm --dir "$here" run --silent build
    printf 'compiled %s\n' "$(ls "$here/dist"/*.js | tr '\n' ' ')"
fi
