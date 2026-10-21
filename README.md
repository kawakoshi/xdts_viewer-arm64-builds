
[日本語はこちら](./doc/README_ja.md)

# XDTS Viewer

<img src=./doc/image.png>

## What is XDTS Viewer?

XDTS Viewer is a software to view XDTS files and draw notes like a paper exposure sheet. The main features are as follows:

- Consistency : It reproduces as much as possible the layout of the paper timesheets which have been long used in the Japanese animation industry.
- Simplisity : As the name implies, this software (for now) can only view XDTS files, not edit them. It focuses on the ability to manually draw all sorts of information not contained in the XDTS file wherever you want, keeping it simple to use.

## Program Requirements

Please refer to the OpenToonz site at <https://opentoonz.github.io/e/index.html>.

## Installation

- Please download a zipped binary of XDTS Viewer from <https://opentoonz.github.io/e/download/xdts_viewer.html>.
- Note that this software is initially configured with Japanese language interface. To change it to English, please do as follows:
  1. Select "環境設定" from the hamburger menu in the upper right corner of the window.
  1. Select "English" from the "言語" combo box.
  1. Launch XDTS Viewer again.

<img src=./doc/language.png>

## Apple Silicon arm64 distribution

This fork provides an unofficial macOS arm64 build for Apple Silicon Macs. It
is not an OpenToonz release and is not endorsed or maintained by OpenToonz.

The private GitHub Release is the distribution source. Each `vX.Y.Z` tag runs
the macOS arm64 GitHub Actions workflow, which builds and ad-hoc signs
`xdts_viewer_arm64.app`, packages it as a DMG, and attaches the DMG and its
SHA-256 file to the Release. Developer ID signing and notarization are not
configured yet, so macOS may show a first-launch warning.

To reproduce the package locally on an Apple Silicon Mac with Homebrew Qt 5:

```zsh
./scripts/package-macos-arm64.sh 1.3.0
```

The generated DMG is written under `artifacts/`, which is intentionally
ignored by Git.

## How to Build Locally

- [Windows](./doc/how_to_build_win.md)
- [MacOS X](./doc/how_to_build_macosx.md)

## Community

- If you found a bug with the software after troubleshooting, or are a developer, search the [Github issues](https://github.com/opentoonz/xdts_viewer/issues) and post there.

## Licensing

[modified BSD license](./LICENSE)
  - Based on this license, this software may be used or changed freely for business or personal use.
