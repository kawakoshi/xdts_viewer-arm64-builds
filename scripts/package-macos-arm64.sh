#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 <version, for example 1.3.0>" >&2
  exit 2
fi

QTDIR="${QTDIR:-$(brew --prefix qt@5)}"
BUILD_DIR="${ROOT_DIR}/build-arm64-release"
STAGE_DIR="${ROOT_DIR}/artifacts/stage"
DIST_DIR="${ROOT_DIR}/artifacts"
APP_PATH="${BUILD_DIR}/xdts_viewer.app"
STAGED_APP_PATH="${STAGE_DIR}/xdts_viewer_arm64.app"
DMG_PATH="${DIST_DIR}/xdts_viewer_arm64_v${VERSION}_macos.dmg"
CHECKSUM_PATH="${DMG_PATH}.sha256"

rm -rf "$BUILD_DIR" "$STAGE_DIR"
mkdir -p "$DIST_DIR" "$STAGE_DIR"

cmake -S "${ROOT_DIR}/sources" \
  -B "$BUILD_DIR" \
  -G Ninja \
  -DQTDIR="$QTDIR" \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_TRANSLATION=OFF

cmake --build "$BUILD_DIR" --parallel

cp -R "${ROOT_DIR}/xdts_viewer_resources" \
  "${APP_PATH}/Contents/MacOS/xdts_viewer_resources"
"${QTDIR}/bin/macdeployqt" "$APP_PATH" -verbose=1 -always-overwrite

codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
test "$(file -b "$APP_PATH/Contents/MacOS/xdts_viewer")" = \
  "Mach-O 64-bit executable arm64"

ditto --norsrc --noextattr "$APP_PATH" "$STAGED_APP_PATH"
plutil -replace CFBundleIdentifier -string \
  io.github.opentoonz.XDTSViewer.arm64 \
  "${STAGED_APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleName -string xdts_viewer_arm64 \
  "${STAGED_APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleDisplayName -string xdts_viewer_arm64 \
  "${STAGED_APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "$VERSION" \
  "${STAGED_APP_PATH}/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$VERSION" \
  "${STAGED_APP_PATH}/Contents/Info.plist"

codesign --force --deep --sign - "$STAGED_APP_PATH"
codesign --verify --deep --strict --verbose=2 "$STAGED_APP_PATH"

rm -f "$DMG_PATH" "$CHECKSUM_PATH"
hdiutil create \
  -volname "XDTS Viewer arm64 ${VERSION}" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

(cd "$DIST_DIR" && shasum -a 256 "$(basename "$DMG_PATH")" > "$(basename "$CHECKSUM_PATH")")

echo "DMG: $DMG_PATH"
echo "SHA-256: $CHECKSUM_PATH"
