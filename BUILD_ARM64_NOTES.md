# XDTS Viewer arm64 local build notes

XDTS Viewer v1.3.0 を Apple Silicon 向けにローカルビルドしたときの記録です。
This document records the local Apple Silicon build steps for XDTS Viewer v1.3.0.

このビルドは非公式です。このリポジトリおよびリリースは、OpenToonz 公式のものではなく、OpenToonz による承認・保守も受けていません。
This is an unofficial build. This repository/release is not affiliated with, endorsed by, or maintained by OpenToonz.

Date: 2026-07-31

## Result / 結果

- Build app / ビルド後 app: `build-arm64/xdts_viewer.app`
- Packaged app / pkg に入れる app: `pkgroot/Applications/xdts_viewer_arm64.app`
- Installer artifact / インストーラ成果物: `artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg`
- Source / 元ソース: `https://github.com/opentoonz/xdts_viewer`
- Version/tag / バージョン/タグ: `v1.3.0`
- Commit / コミット: `91b8443`
- Architecture / アーキテクチャ: `arm64`
- Packaged bundle identifier / 配布用 Bundle ID: `io.github.opentoonz.XDTSViewer.arm64`
- Packaged display name / 配布用表示名: `xdts_viewer_arm64`
- Icon source / アイコン元ファイル: `/Users/mba2026/Documents/codex_hisyo/TSX-Project/TSX-Core/sources/XDTS_Viewer_arm64.icns`
- App signing / アプリ署名: ad-hoc signed with `codesign --force --deep --sign -`
- Package signing / pkg 署名: unsigned / 未署名
- Local launch check / ローカル起動確認: launched from `build-arm64/xdts_viewer.app`

## Local Prerequisites Used / 使用したローカル環境

- CMake: `4.4.0`
- Qt: Homebrew `qt@5`, detected at `/opt/homebrew/opt/qt@5`
- Xcode Command Line Tools were enough for this local CMake build.
  - このローカル CMake ビルドでは Xcode Command Line Tools だけで足りました。
- Full Xcode was not installed, so the upstream Xcode project workflow was not used.
  - フル版 Xcode は未インストールだったため、本家の Xcode project workflow は使っていません。

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

## Verification / 検証

```zsh
file build-arm64/xdts_viewer.app/Contents/MacOS/xdts_viewer
pkgutil --check-signature artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg
pkgutil --expand-full artifacts/xdts_viewer_arm64_v1.3.0_macos.pkg /private/tmp/xdts_viewer_arm64_pkg_check
cmp -s /Users/mba2026/Documents/codex_hisyo/TSX-Project/TSX-Core/sources/XDTS_Viewer_arm64.icns /private/tmp/xdts_viewer_arm64_pkg_check/Payload/Applications/xdts_viewer_arm64.app/Contents/Resources/XDTS_Viewer.icns
codesign --verify --deep --strict --verbose=2 /private/tmp/xdts_viewer_arm64_pkg_check/Payload/Applications/xdts_viewer_arm64.app
```

Expected / 期待される結果:

```text
Mach-O 64-bit executable arm64
Icon cmp exit status: 0
Package signing status: no signature
Extracted app: valid on disk
```

## Notes / メモ

- The upstream macOS release package is x86_64-only.
  - 本家の macOS リリース pkg は x86_64 のみです。
- The project did not require source changes for an arm64 local build.
  - arm64 ローカルビルドにあたって、ソースコード変更は不要でした。
- The CMake file has a default macOS deployment target of `10.10`; this build overrides it to `11.0`, which is the practical floor for Apple Silicon.
  - CMake のデフォルト macOS deployment target は `10.10` ですが、このビルドでは Apple Silicon の実用的な下限として `11.0` を指定しています。
- The build app keeps the upstream bundle identifier, but the packaged app is renamed to `xdts_viewer_arm64.app` and uses `io.github.opentoonz.XDTSViewer.arm64` so it can coexist with the official `/Applications/xdts_viewer.app`.
  - ビルド直後の app は本家 Bundle ID のままですが、pkg に入れる app は `xdts_viewer_arm64.app` にリネームし、Bundle ID も `io.github.opentoonz.XDTSViewer.arm64` に変更しています。これにより公式版 `/Applications/xdts_viewer.app` と共存できます。
- The pkg installs `xdts_viewer_arm64.app` into `/Applications`.
  - pkg は `/Applications` に `xdts_viewer_arm64.app` をインストールします。
- Without an Apple Developer ID Installer certificate, the pkg itself remains unsigned. For personal/local use this is fine; public distribution should use Developer ID signing and notarization.
  - Apple Developer ID Installer 証明書がないため、pkg 自体は未署名です。個人利用や限定配布ならこのままでも扱えますが、広く配布する場合は Developer ID 署名と notarization を行うべきです。
