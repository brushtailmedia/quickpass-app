# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project follows Semantic Versioning.

## [Unreleased]

Forked from `quickpass-desktop` v1.0.0 as `quickpass-app`, adding mobile targets.

### Added
- Android and iOS targets via Tauri 2 mobile (`src-tauri/gen/android`, `src-tauri/gen/apple`).
- npm scripts: `android:dev`, `android:build`, `ios:dev`, `ios:build`.
- Tauri clipboard plugin (`tauri-plugin-clipboard-manager`) used for copy/clear on all platforms, with web clipboard fallback.
- `src-tauri/capabilities/default.json` granting `core:default` and `clipboard-manager:allow-write-text`.
- Mobile layout: safe-area insets, `100dvh`, 16px inputs and larger touch targets below 760px.
- "Change password output length:" heading above the length options in Extras, so the stacked mobile layout does not read as one group with "Allow all special characters".
- QuickPass launcher and app icons in the generated Android and iOS projects (replacing the Tauri template defaults).
- `mobile-matrix.yml` workflow: unsigned Android APK/AAB and iOS simulator builds on PR and push.
- Signed Android (APK/AAB) and iOS (IPA) jobs in `tauri-release.yml`, gated on signing secrets.
- Release builds use the GitHub run number as Android `versionCode` and iOS `CFBundleVersion`, so repeated uploads of one version are accepted by both stores.
- Android release signing config in `build.gradle.kts`, read from a git-ignored `keystore.properties`.

### Fixed
- Site name input no longer autocorrects, autocapitalizes or spellchecks on mobile keyboards (a corrected site name silently changes the output).
- Master password uses `autoComplete="current-password"` so iOS stops offering "Use Strong Password", which would replace the master password with a random one.
- iOS launch screen uses the app background colour instead of flashing white; status bar text is light.
- Android native library is linked with 16 KB page alignment (`src-tauri/build.rs`), as Google Play requires for apps targeting Android 15+.
- README screenshot is now the iOS app, not the desktop app.
- Phones are locked to portrait (iPhone via `Info.plist`, Android via `MainActivity.kt`); iPad and Android tablets rotate freely, as both stores require for large screens.

### Security
- Copy uses the clipboard plugin's `writeSecret` (sensitive on Android, local-only on iOS); all clears use the native `clear` (no Android toast). Permissions: `clipboard-manager:allow-write-secret`, `allow-clear`.
- Editing any field after a copy clears the stale password from the clipboard; the form is kept.
- Red "Always Clear Clipboard once done" status line while a copied password is outstanding.
- Both "show" toggles turn off when the app loses focus.
- Android `FLAG_SECURE` (no screenshots, recording or recents thumbnail). iOS blur overlay on resign-active hides the form from the app switcher.
- CSP set to `default-src 'self'; connect-src ipc: http://ipc.localhost`; a separate `devCsp` allows Vite HMR in dev.
- Android: `INTERNET` permission moved to the debug source set; release APK/AAB request no permissions.
- Android: `allowBackup="false"`.

### Removed
- Desktop release surface: `tauri-matrix.yml`, `tauri-build.yml`, the desktop jobs in the release workflow, desktop icon files, and the `tauri:build` script. Desktop builds continue in `quickpass-desktop`.

### Changed
- Release workflow renamed to `mobile-release.yml`; it publishes Android and iOS assets only.
- `tauri:dev` kept for local UI iteration in a desktop window.
- Rust crate split into `lib.rs` (shared entry, `mobile_entry_point`) and `main.rs` (desktop dev binary).
- App identifier changed to `com.quickpass.app`.
- Package renamed to `quickpass-app`.
- Tauri crates and npm packages updated to 2.12.x.

## [1.0.0] - 2026-05-16

First public `v1` release of the standalone QuickPass desktop app after long-term private use.

### Added
- Standalone Tauri desktop project structure for independent GitHub publishing.
- Release-ready project documentation in `README.md` (overview, setup, build, security model, known risks).
- Deterministic vector test suite (`npm run test:vectors`) for algorithm/output verification.
- UI/unit test suite with Vitest + Testing Library (`npm run test`).
- Static analysis checks for JavaScript and Rust (`npm run static:check`):
  - ESLint
  - `cargo fmt --check`
  - `cargo clippy -D warnings`
- Node version pinning via `.nvmrc` (`v24.14.0`) for consistent local and CI builds.
- Hardened `.gitignore` coverage for Node, Vite, Tauri/Rust build outputs, installer artifacts, and local machine files.
- GitHub Actions workflows for matrix and release builds across Windows, Linux, macOS arm64, and macOS Intel.

### Changed
- Limited special-character mode charset updated to:
  - `abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=`
- Limited-mode vector expectations updated to match the new deterministic output.
- Package renamed for standalone distribution:
  - `quickpass-desktop`
- README and scripts aligned to standalone usage (no monorepo workspace flags required).
- CI/release workflows now run both unit/UI tests and deterministic vector tests (`npm run test:all`) before building.
- CI/release workflows now run static checks before tests and builds.

### Security
- Password generation remains local and deterministic (no backend required).
- No browser storage APIs are used by app logic (`localStorage`, `sessionStorage`, `IndexedDB`).
- Clipboard operations remain explicit user actions (copy/clear flows).

### Notes
- `src-tauri/Cargo.lock` is intentionally tracked for reproducible Rust builds.
- Build artifacts under `dist/` and `src-tauri/target/` are intentionally ignored.
