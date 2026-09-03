# Troubleshooting

## Symptom: `flutter test` hangs, then crashes

```
Unexpected Kernel Format Version 127 (expected 138)
```

## Cause: Dart / Flutter version mismatch

This system had the **AUR `flutter` package** (3.41.2, which bundles Dart 3.11)
installed alongside the **system `dart` package** (3.13.2). The AUR package
patches Flutter (`system-dart.patch`) to use `/opt/dart-sdk` instead of its own
Dart. When the system Dart drifts ahead of the Flutter package's expected Dart,
their kernel-binary formats diverge and the compiler hard-crashes.

The AUR `flutter` package splits upstream Flutter into ~16 sub-packages and
applies 7 patches to make it FHS-compliant and system-managed. That is valuable
for distro packaging, but fragile for development: any `dart` upgrade can break
`flutter` until the AUR package catches up.

## Fix in place: upstream Flutter in $HOME

Upstream Flutter ships its own matching Dart SDK. No patches, no drift.

Already done on this machine:

```bash
git clone -b stable https://github.com/flutter/flutter.git ~/flutter
```

PATH prepend added to `~/.config/fish/config.fish`:

```fish
set -gx PATH $HOME/flutter/bin $PATH
```

`~/flutter/bin` is prepended, so it shadows `/usr/bin/flutter` from the AUR
package. New fish shells pick this up automatically. Verify:

```bash
which flutter   # -> /home/chardlinux/flutter/bin/flutter
which dart      # -> /home/chardlinux/flutter/bin/dart
flutter --version
```

## Optional: remove the AUR packages (needs sudo)

The AUR `flutter 3.41.2-*` packages are now harmless leftovers (shadowed by
PATH), but removing them eliminates future confusion:

```bash
sudo pacman -Rns $(pacman -Qqs '^flutter')
```

Leave `dart` installed if other tools depend on it; it no longer affects
Flutter. If you want a clean slate:

```bash
sudo pacman -Rns flutter dart
```

## Revisiting this repo later

```bash
cd ~/SynologyDrive/Development/random/flutter-vibe-helper
flutter pub get
flutter test            # 5 tests, ~4s
flutter run -d linux   # desktop app
```

If `which flutter` ever resolves to `/usr/bin/flutter` again, the PATH order
changed. Re-export or check `~/.config/fish/config.fish`.

## Noise you can ignore

- `file_picker` warnings about missing inline implementations for
  linux/macos/windows — harmless plugin declarations, tests pass regardless.
- First `flutter` run downloads the Dart SDK and builds the tool (~30s one-time).
