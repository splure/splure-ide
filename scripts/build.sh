#!/usr/bin/env bash
# Builds Spluride for one platform. Run scripts/prepare.sh first.
# Usage: scripts/build.sh <linux|darwin|win32> <x64|arm64>
# Output: ../VSCode-<platform>-<arch>/ next to ./vscode (upstream's layout), then archived to ./dist
set -euo pipefail

PLATFORM="${1:?platform: linux | darwin | win32}"
ARCH="${2:?arch: x64 | arm64}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/vscode"
# shellcheck disable=SC1091
source "$ROOT/upstream.env"

cd "$SRC"
# Upstream pins its pnpm version in package.json's "packageManager"; corepack honours it.
corepack enable
export ELECTRON_SKIP_BINARY_DOWNLOAD=1 PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
export npm_config_arch="$ARCH"

echo "==> Installing dependencies"
for i in 1 2 3; do pnpm install --frozen-lockfile && break; echo "pnpm install failed ($i), retrying"; sleep 10; done

echo "==> Building vscode-$PLATFORM-$ARCH-min"
pnpm run gulp "vscode-$PLATFORM-$ARCH-min"

OUT="$ROOT/VSCode-$PLATFORM-$ARCH"
mkdir -p "$ROOT/dist"
NAME="Spluride-$PLATFORM-$ARCH-$VSCODE_TAG"
echo "==> Archiving $NAME"
case "$PLATFORM" in
	linux)  tar -czf "$ROOT/dist/$NAME.tar.gz" -C "$OUT" . ;;
	darwin) (cd "$OUT" && ditto -c -k --sequesterRsrc --keepParent Spluride.app "$ROOT/dist/$NAME.zip") ;;
	win32)  (cd "$OUT" && 7z a -tzip "$ROOT/dist/$NAME.zip" . >/dev/null) ;;
esac
ls -lh "$ROOT/dist"
