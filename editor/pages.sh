#!/usr/bin/env bash
# Assemble a static site for GitHub Pages into dist/ at the repository root.
#
#   ./editor/pages.sh && python -m http.server -d dist 8001
#
# Everything is relative, so the site works at a project path
# (user.github.io/repo/) as well as at a domain root.  Run ./editor/build.sh
# first; this only copies what that produced.
#
# The wasm module carries the complete filter bank and parameter metadata.
# Keep the assembled site inside the project's authorized environments.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$here")"
out="$root/dist"

for needed in "$here/dist/app.js" "$here/pkg/gltcstdio_wasm_bg.wasm"; do
    [[ -f "$needed" ]] || { echo "missing $needed -- run ./editor/build.sh first" >&2; exit 1; }
done

rm -rf "$out"
mkdir -p "$out/js" "$out/pkg"

cp "$here/index.html" "$here/app.css" "$out/"
# The compiled page moves to js/, from which its `../pkg/` import still
# resolves; the script tag is the only reference that has to follow.
cp "$here"/dist/*.js "$out/js/"
sed -i 's|src="dist/app.js"|src="js/app.js"|' "$out/index.html"
# Only what the page loads: the glue and the module itself.
cp "$here/pkg/gltcstdio_wasm.js" "$here/pkg/gltcstdio_wasm_bg.wasm" "$out/pkg/"
# Pages runs Jekyll otherwise, which drops files and directories it does not
# recognise.
touch "$out/.nojekyll"

printf 'dist/ built: %s across %s files\n' \
    "$(du -sh "$out" | cut -f1)" "$(find "$out" -type f | wc -l)"
find "$out" -type f -printf '  %P (%s bytes)\n' | sort
