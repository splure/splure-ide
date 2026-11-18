#!/usr/bin/env bash
# Fetches upstream VS Code at the pinned tag into ./vscode and applies Spluride on top:
#   1. product.json branding (product.overrides.json)
#   2. built-in extensions from ./extensions (clean UI themes + defaults)
#   3. any source patches in ./patches/*.patch
#   4. icons from ./branding, if present
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/upstream.env"
SRC="$ROOT/vscode"

if [[ -d "$SRC/.git" ]]; then
	echo "==> Resetting existing checkout to $VSCODE_TAG"
	git -C "$SRC" fetch --depth 1 origin "refs/tags/$VSCODE_TAG:refs/tags/$VSCODE_TAG"
	git -C "$SRC" checkout -q -f "$VSCODE_TAG"
	git -C "$SRC" clean -q -fdx -e node_modules -e '**/node_modules'
else
	echo "==> Cloning $VSCODE_REPO @ $VSCODE_TAG"
	git -c advice.detachedHead=false clone -q --depth 1 --branch "$VSCODE_TAG" "$VSCODE_REPO" "$SRC"
fi

echo "==> Branding"
node "$ROOT/scripts/merge-product.mjs" "$SRC/product.json" "$ROOT/product.overrides.json"

echo "==> Built-in extensions"
for ext in "$ROOT"/extensions/*/; do
	name="$(basename "$ext")"
	rm -rf "$SRC/extensions/$name"
	cp -R "$ext" "$SRC/extensions/$name"
	echo "    + $name"
done

shopt -s nullglob
patches=("$ROOT"/patches/*.patch)
if (( ${#patches[@]} )); then
	echo "==> Patches"
	for p in "${patches[@]}"; do
		echo "    + $(basename "$p")"
		git -C "$SRC" apply --whitespace=nowarn "$p"
	done
fi

echo "==> Icons"
copy_icon() { [[ -f "$ROOT/branding/$1" ]] && cp "$ROOT/branding/$1" "$SRC/$2" && echo "    + $1"; return 0; }
copy_icon code.png  resources/linux/code.png
copy_icon code.icns resources/darwin/code.icns
copy_icon code.ico  resources/win32/code.ico

echo "==> Ready: $SRC"
