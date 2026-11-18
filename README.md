# Spluride

A fork of [VS Code](https://github.com/microsoft/vscode) (Code - OSS) with a clean UI.

This repo doesn't vendor VS Code's source. It pins an upstream release and layers Spluride on top at build time, the same approach VSCodium uses. Staying current with Microsoft is just a version bump.

## What's different from VS Code

**Branding.** The app is Spluride throughout: its own app name, data folder (`~/.spluride`), bundle ID and Windows registry IDs. It installs side by side with VS Code without conflicts.

**Clean UI** (`extensions/spluride-clean`):
- Spluride Dark and Spluride Light themes: one continuous surface colour, with no borders between the sidebar, editor, panel, tabs, title bar and status bar. Text is quieter, and a single accent marks what's active.
- Quieter defaults:
  - activity bar moved into the sidebar header
  - no minimap, breadcrumbs, sticky scroll, command centre, layout buttons or overview-ruler border
  - no welcome page, tips or empty-editor hint
  - built-in AI and chat UI hidden
  - smooth scrolling and caret animation

Users can override all of these in Settings as usual.

**Extensions.** Extensions come from [Open VSX](https://open-vsx.org), since Microsoft's marketplace terms don't allow forks.

## Layout

```
upstream.env                  pinned VS Code release (VSCODE_TAG)
product.overrides.json        branding merged into upstream product.json
extensions/spluride-clean/    themes + default settings, shipped as a built-in extension
patches/                      optional source patches (*.patch)
branding/                     optional app icons
scripts/prepare.sh            clone upstream @ tag, apply all of the above → ./vscode
scripts/build.sh              install deps, build, archive → ./dist
.github/workflows/build.yml   CI builds for Linux x64/arm64, macOS arm64, Windows x64
```

## Building

### In CI (recommended)

1. Push this repo to GitHub.
2. Run **Actions → Build Spluride → Run workflow**.
3. To publish a release with all platform archives attached, push a tag:
   ```sh
   git tag v1.146.0 && git push --tags
   ```

### Locally

You need the Node version in `vscode/.nvmrc` (24.x), Python 3, Git and a C/C++ toolchain. On Linux you also need `libxkbfile-dev`, `libkrb5-dev` and `libsecret-1-dev`. Expect around 16 GB of RAM and 30–60 minutes.

```sh
scripts/prepare.sh
scripts/build.sh linux x64      # or: darwin arm64 / win32 x64
```

The app lands in `VSCode-<platform>-<arch>/` and an archive in `dist/`.

To iterate on the UI without a full build, run upstream's dev mode:

```sh
cd vscode && corepack enable && pnpm install && pnpm run watch   # leave running
./scripts/code.sh                                                 # in another terminal
```

## Updating to a new VS Code release

1. Change `VSCODE_TAG` in `upstream.env`.
2. Run `scripts/prepare.sh`. It warns if upstream renamed a `product.json` key, and fails loudly if a patch no longer applies.
3. Build and commit.

## Notes

- **Unsigned builds.** On macOS, Gatekeeper blocks unsigned apps on first launch: right-click → Open, or run `xattr -cr Spluride.app`. Windows SmartScreen shows a similar warning. Signing needs your own Apple Developer ID and Windows code-signing certificate.
- **Microsoft-only extensions.** Some extensions (Pylance, C# Dev Kit, Remote-SSH, Live Share) are licensed for Microsoft's VS Code only. Open VSX alternatives exist for most of them, such as basedpyright and Open Remote - SSH.
- **Bundle ID.** The macOS bundle ID is `cc.splure.spluride`. Change it in `product.overrides.json` before your first public release, because changing it later resets users' settings location on macOS.

## License

MIT. VS Code's source is © Microsoft Corporation, MIT-licensed. See `LICENSE`.
