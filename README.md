# YTD M3

A native Flutter desktop client for macOS, Windows, and Linux, built with
Material 3. It doesn't do any downloading itself — it's a control panel that
talks to a download **server**, which can be:

- **This computer** — run the server locally and use the app as a front end.
- **A remote server** — your own box on the network, or a server a friend is
  hosting for you.

Mobile is intentionally out of scope for local/on-device serving. A future
Android build is remote-client-only: no on-device server, no local mode, and
no support for running it under Termux.

## Status

This repository currently ships the desktop shell: navigation, the M3 theme
customizer, server profile management (add/edit/connect), and settings
(including the legal-warning toggle described below). The actual download
server and its protocol are not implemented yet — "Set up a server on this
computer" currently just registers a local server profile in the app; wiring
it to a real backend is future work.

## Design constraints

- **Material 3 only.** Every screen is built from stock Flutter Material 3
  widgets (`NavigationRail`, `Card`, `SegmentedButton`, etc.) and Material
  Icons — no custom-drawn graphics or bundled image assets.
- **Typography.** The brief called for Google Sans globally, but Google Sans
  is a proprietary Google product font that isn't published on Google Fonts,
  so `google_fonts` has nothing to fetch for it. [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart)
  uses **Roboto** instead — Google's own open-source Material typeface — as
  the closest properly licensed stand-in. Swap `GoogleFonts.robotoTextTheme`
  there if a licensed Google Sans font file ever becomes available.
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
flutter run -d linux   # or macos / windows
```

Supported platforms: `linux`, `macos`, `windows`. Mobile platforms are not
part of this project's `flutter create` scaffold.
