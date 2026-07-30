## 日本語

XDTS Viewer v1.3.0 を Apple Silicon 向けにビルドした非公式版です。
OpenToonz 公式の配布物ではなく、OpenToonz による承認・保守も受けていません。

### 成果物

- `xdts_viewer_arm64_v1.3.0_macos.pkg`

### 内容

- `/Applications/xdts_viewer_arm64.app` としてインストールされます。
- Bundle ID は `io.github.opentoonz.XDTSViewer.arm64` です。
- 公式版の `/Applications/xdts_viewer.app` と共存できます。
- アプリ本体は `arm64` バイナリです。
- arm64 ビルド用のアイコンに差し替えています。
- アプリ本体は ad-hoc 署名です。
- pkg は未署名で、notarization も未実施です。初回起動時に Gatekeeper の警告が出る場合があります。

ビルド手順は `BUILD_ARM64_NOTES.md` に記録しています。

## English

This is an unofficial Apple Silicon build of XDTS Viewer v1.3.0.
It is not an official OpenToonz release, and is not endorsed or maintained by OpenToonz.

### Asset

- `xdts_viewer_arm64_v1.3.0_macos.pkg`

### Notes

- Installs as `/Applications/xdts_viewer_arm64.app`.
- Uses bundle ID `io.github.opentoonz.XDTSViewer.arm64`.
- Can coexist with the official `/Applications/xdts_viewer.app`.
- The app binary is `arm64`.
- The icon is customized for this arm64 build.
- The app is ad-hoc signed.
- The pkg is unsigned and not notarized. Gatekeeper may warn on first launch.

Build steps are documented in `BUILD_ARM64_NOTES.md`.
