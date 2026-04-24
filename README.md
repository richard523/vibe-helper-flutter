# Flutter Vibe Helper

A cross-platform (mobile + desktop + web) dashboard for Mistral Vibe CLI analytics and management.

## Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Linux | ✅ Supported |
| macOS | ✅ Supported |
| Windows | ✅ Supported |
| Web | ✅ Supported |

## Quick Start

```bash
# Clone & enter
cd flutter-vibe-helper

# Get dependencies
flutter pub get

# Run for your platform
flutter run -d linux    # Linux desktop
flutter run -d macos    # macOS desktop
flutter run -d windows  # Windows desktop
flutter run -d android  # Android device/emulator
flutter run -d ios      # iOS device/simulator
flutter run -d chrome   # Web

# Build
flutter build linux
flutter build apk
flutter build ios
flutter build web
```

## Project Structure

```
lib/
  main.dart           # App entry point
  app/               # App configuration & routing
  screens/           # UI screens
  widgets/          # Reusable widgets
  models/           # Data models
  services/         # Business logic & data services
  utils/            # Utilities & helpers
  theme/            # App theming
assets/
  images/
  fonts/
```
