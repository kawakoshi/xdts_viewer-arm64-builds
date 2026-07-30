# XDTS Viewer arm64 local build notes

Date: 2026-07-31

## Result

- Build app: `build-arm64/xdts_viewer.app`
- Packaged app: `pkgroot/Applications/xdts_viewer_arm64.app`
- Installer artifact: `artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg`
- Source: `https://github.com/opentoonz/xdts_viewer`
- Version/tag: `v1.3.0`
- Commit: `91b8443`
- Architecture: `arm64`
- Packaged bundle identifier: `io.github.opentoonz.XDTSViewer.arm64`
- Packaged display name: `xdts_viewer_arm64`
- Icon source: `/Users/mba2026/Documents/codex_hisyo/TSX-Project/TSX-Core/sources/XDTS_Viewer_arm64.icns`
- App signing: ad-hoc signed with `codesign --force --deep --sign -`
- Package signing: unsigned
- Local launch check: launched from `build-arm64/xdts_viewer.app`

## Local prerequisites used

- CMake: `4.4.0`
- Qt: Homebrew `qt@5`, detected at `/opt/homebrew/opt/qt@5`
- Xcode Command Line Tools were enough for this local CMake build.
- Full Xcode was not installed, so the upstream Xcode project workflow was not used.

## Commands

```zsh
git clone https://github.com/opentoonz/xdts_viewer.git sources
git -C sources checkout v1.3.0

cmake -S sources \
  -B build-arm64 \
  -DQTDIR=/opt/homebrew/opt/qt@5 \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
  -DCMAKE_BUILD_TYPE=Release \
  -DWITH_TRANSLATION=OFF

cmake --build build-arm64 --config Release --parallel 8

/opt/homebrew/opt/qt@5/bin/macdeployqt build-arm64/xdts_viewer.app \
  -verbose=1 \
  -always-overwrite

cp -R xdts_viewer_resources \
  build-arm64/xdts_viewer.app/Contents/MacOS/xdts_viewer_resources

cp /Users/mba2026/Documents/codex_hisyo/TSX-Project/TSX-Core/sources/XDTS_Viewer_arm64.icns \
  build-arm64/xdts_viewer.app/Contents/Resources/XDTS_Viewer.icns

codesign --force --deep --sign - build-arm64/xdts_viewer.app
codesign --verify --deep --strict --verbose=2 build-arm64/xdts_viewer.app

mkdir -p pkgroot/Applications

ditto --norsrc --noextattr \
  build-arm64/xdts_viewer.app \
  pkgroot/Applications/xdts_viewer_arm64.app

plutil -replace CFBundleIdentifier -string io.github.opentoonz.XDTSViewer.arm64 \
  pkgroot/Applications/xdts_viewer_arm64.app/Contents/Info.plist

plutil -replace CFBundleName -string xdts_viewer_arm64 \
  pkgroot/Applications/xdts_viewer_arm64.app/Contents/Info.plist

plutil -replace CFBundleDisplayName -string xdts_viewer_arm64 \
  pkgroot/Applications/xdts_viewer_arm64.app/Contents/Info.plist

codesign --force --deep --sign - pkgroot/Applications/xdts_viewer_arm64.app

/usr/bin/env COPYFILE_DISABLE=1 pkgbuild \
  --root pkgroot \
  --identifier io.github.opentoonz.XDTSViewer.arm64.pkg \
  --version 1.3.0 \
  --install-location / \
  artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg
```

## Verification

```zsh
file build-arm64/xdts_viewer.app/Contents/MacOS/xdts_viewer
pkgutil --check-signature artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg
pkgutil --expand-full artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg /private/tmp/xdts_viewer_arm64_pkg_check
cmp -s /Users/mba2026/Documents/codex_hisyo/TSX-Project/TSX-Core/sources/XDTS_Viewer_arm64.icns /private/tmp/xdts_viewer_arm64_pkg_check/Payload/Applications/xdts_viewer_arm64.app/Contents/Resources/XDTS_Viewer.icns
codesign --verify --deep --strict --verbose=2 /private/tmp/xdts_viewer_arm64_pkg_check/Payload/Applications/xdts_viewer_arm64.app
```

Expected:

```text
Mach-O 64-bit executable arm64
Icon cmp exit status: 0
Package signing status: no signature
Extracted app: valid on disk
```

## Notes

- The upstream macOS release package is x86_64-only.
- The project did not require source changes for an arm64 local build.
- The CMake file has a default macOS deployment target of `10.10`; this build overrides it to `11.0`, which is the practical floor for Apple Silicon.
- The build app keeps the upstream bundle identifier, but the packaged app is renamed to `xdts_viewer_arm64.app` and uses `io.github.opentoonz.XDTSViewer.arm64` so it can coexist with the official `/Applications/xdts_viewer.app`.
- The pkg installs `xdts_viewer_arm64.app` into `/Applications`.
- Without an Apple Developer ID Installer certificate, the pkg itself remains unsigned. For personal/local use this is fine; public distribution should use Developer ID signing and notarization.
