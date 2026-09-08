# YTD M3

A native Flutter client for macOS, Windows, Linux, and Android, built with
Material 3. It doesn't do any downloading itself — it's a control panel that
optionally talks to a remote download **server**.

- **Direct (desktop only, default)** — no server, no setup. The app works on
  its own out of the box.
- **A remote server (optional, all platforms)** — your own box on the
  network, or a server a friend is hosting for you.

Android is remote-server-only: there is no Direct mode and no on-device
server there, and running this app under Termux is unsupported. Desktop
(macOS/Windows/Linux) supports both Direct and remote.

## Status

This repository ships the app shell — navigation (adaptive between a
`NavigationRail` on desktop/tablet and a bottom `NavigationBar` on phones),
the M3 theme customizer, remote server management, the legal-warning toggle,
and working Home quick actions (new download, opening the local downloads
folder, and download history). There is still no bundled download engine —
queuing a download in Direct mode is recorded honestly as unsupported until
one exists; queuing against a remote server does a real HTTP POST to
`<server>/api/downloads`, which will fail until an actual server
implementing that endpoint exists.

## Design constraints

- **Material 3 only.** Every screen is built from stock Flutter Material 3
  widgets (`NavigationRail`, `NavigationBar`, `Card`, `SegmentedButton`, etc.)
  and Material Icons — no custom-drawn graphics or bundled image assets.
- **Typography.** Google Sans is set globally via `GoogleFonts.googleSansTextTheme`
  in [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart) (requires
  `google_fonts` ^8.2.1 or later — older releases predate Google Sans being
  published on Google Fonts).
- **Theme customizer.** Settings → Appearance lets you pick a Material seed
  color (feeds `ColorScheme.fromSeed`) and switch light/dark/system mode.

## Legal warning

The Home screen shows a notice reminding you to only download content you
have the rights to. Settings → Legal can turn this off, but only after
confirming through a dialog that requires typing a confirmation phrase — it's
not a plain toggle, since disabling it has real legal implications for how
you use the app.

## Getting started

```
flutter pub get
flutter run -d linux   # or macos / windows / android
```

## Packaging

CI (`.github/workflows/build.yml`) builds every push to `main`:

- **Linux** — built natively for both x86_64 and arm64 (GitHub's
  `ubuntu-24.04-arm` runner), each packaged as a `.deb` and `.rpm` via
  [`fpm`](https://fpm.readthedocs.io/), alongside the raw bundle.
- **macOS** — a universal (arm64 + x86_64) `.app` bundle, Flutter's default
  for `flutter build macos`.
- **Windows** — an x86_64 release build.
- **Android** — a release APK covering `arm64-v8a`, `armeabi-v7a`, and
  `x86_64` in one universal build.

Pushing a tag matching `v*` additionally creates a GitHub Release with all
of the above attached.
