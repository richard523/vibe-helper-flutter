# Flutter Vibe Helper

<p align="center">
  <img src="assets/vibe-helper-icon.png" alt="Flutter Vibe Helper Icon" width="200" height="200">
</p>

<p align="center">A cross-platform (mobile + desktop + web) dashboard for Mistral Vibe CLI analytics and management.</p>

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

## Installation

### Linux (Standalone App)

#### From GitHub Releases
1. Download `flutter_vibe_helper-linux-x64.tar.gz` from [Releases](https://github.com/richard523/vibe-helper-flutter/releases)
2. Extract the archive:
   ```bash
   tar -xzvf flutter_vibe_helper-linux-x64.tar.gz
   ```
3. Run the app:
   ```bash
   cd flutter_vibe_helper
   ./run.sh
   ```
   Or double-click `run.sh` in your file manager (ensure it has execute permissions).

#### Install System-Wide (Optional)
```bash
# Copy to /opt
sudo cp -r flutter_vibe_helper /opt/

# Install desktop entry for application menu
sudo cp flutter_vibe_helper/flutter_vibe_helper.desktop /usr/share/applications/

# Install icon for application menu (optional)
sudo cp flutter_vibe_helper/icon.png /usr/share/icons/hicolor/256x256/apps/flutter_vibe_helper.png

# Now you can run from terminal or find it in your app menu
flutter_vibe_helper
```

### Windows

#### From GitHub Releases
1. Download `flutter_vibe_helper-windows-x64.zip` from [Releases](https://github.com/richard523/vibe-helper-flutter/releases)
2. Extract the ZIP file
3. Double-click `run.bat` or `flutter_vibe_helper.exe`

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
