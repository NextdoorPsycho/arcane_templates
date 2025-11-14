# Arcane + Beamer Template

A Flutter template combining the Arcane UI framework with Beamer navigation for declarative routing and deep linking support.

## Quick Links

- **[📘 Complete Setup Guide](SETUP.md)** - Comprehensive step-by-step setup instructions
- **[🛠️ Helper Scripts](../scripts/README.md)** - Automated configuration tools

## Overview

This template demonstrates:
- **Pure Arcane UI** - No Material Design components
- **Beamer Navigation** - Declarative routing with deep linking
- **Clean URLs** - Path-based URLs on web (no # in URLs)
- **Multi-platform support** - Web, iOS, Android, Linux, macOS, Windows
- **3-project architecture** - Client app, shared models package, and server
- **Firebase ready** - Optional Firebase integration
- **Server deployment** - Ready for Google Cloud Run

## Features

### UI Framework
- **Arcane Components**: Screen, Bar, Collection, Section, Tile, Card, Gap, Buttons
- **Arcane Extensions**: arcane_fluf, arcane_auth, arcane_user
- **Theme Management**: Built-in light/dark/system theme toggle via `context.toggleTheme()`

### Navigation
- **Beamer**: Declarative routing and navigation
- **Deep Linking**: Automatic deep linking support on all platforms
- **Path-based URLs**: Clean URLs on web (e.g., `/profile` instead of `/#/profile`)
- **Route Management**: Centralized in `lib/routes.dart`

### State Management
- **Pylon**: Immutable and mutable state management
- **RxDart**: Reactive programming support

### Data Layer
- **FireCrud**: Firestore CRUD operations (optional)
- **Hive**: Local storage
- **Artifact**: Data serialization

### Utilities
- **Toxic**: Flutter utility extensions
- **Fast Log**: Logging system
- **Serviced**: Service layer management

## Getting Started

### Option 1: Full Setup (Recommended)

For a complete setup with Firebase, server, and 3-project architecture:

👉 **[Read the Complete Setup Guide](SETUP.md)**

The guide covers:
- Prerequisites and CLI tools
- Firebase project setup (optional)
- 3-project architecture creation
- Dependencies installation
- Beamer navigation configuration
- Platform version configuration
- Icon and splash screen generation
- Firebase deployment (optional)
- Server deployment to Google Cloud Run (optional)

### Option 2: Quick Start (Minimal)

For a quick start without Firebase or server:

```bash
# 1. Create client app
flutter create \
  --platforms=android,ios,web,linux,windows,macos \
  --org art.arcane \
  --project-name my_app \
  my_app

# 2. Navigate to app
cd my_app

# 3. Add Arcane and Beamer dependencies
flutter pub add arcane toxic toxic_flutter pylon rxdart beamer hive hive_flutter

# 4. Copy template code
# Copy lib/ folder from this template to your project
# Key files: main.dart, routes.dart, screens/

# 5. Generate icons and splash (optional)
flutter pub add --dev flutter_launcher_icons
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 6. Run the app
flutter run
```

## Project Structure

```
arcane_beamer/
├── lib/
│   ├── main.dart           # App entry with Beamer setup
│   ├── routes.dart         # Beamer route definitions
│   └── screens/            # Screen widgets
│       ├── home_screen.dart
│       ├── example_screen.dart
│       └── not_found_screen.dart
├── assets/
│   └── icon/               # App icons and splash
│       ├── icon.png        # 1024x1024 app icon
│       └── splash.png      # Splash screen image
├── pubspec.yaml            # Dependencies and asset configuration
├── SETUP.md                # Comprehensive setup guide
└── README.md               # This file
```

## Using This Template

1. **Copy the template**: Clone or copy this directory
2. **Customize assets**: Replace icons and splash screens in `assets/icon/`
3. **Update pubspec.yaml**: Change app name and description
4. **Modify routes**: Add/remove routes in `lib/routes.dart`
5. **Customize screens**: Edit screens in `lib/screens/`
6. **Generate assets**: Run icon and splash generators
7. **Run the app**: `flutter run`

For the 3-project architecture (recommended for production apps), follow the [Complete Setup Guide](SETUP.md).

## Beamer Navigation

### Adding Routes

Edit `lib/routes.dart`:

```dart
final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': route("/", "Home", const HomeScreen()),
      '/example': route("/example", "Example", const ExampleScreen()),
      '/your-route': route("/your-route", "Your Title", const YourScreen()),
    },
  ),
  notFoundRedirectNamed: "/404",
);
```

### Navigation Usage

**Navigate to a route:**
```dart
context.beamToNamed('/example');
```

**Navigate back:**
```dart
context.beamBack();
```

**Route with parameters:**
```dart
// Define route
'/user/:userId': route("/user/:userId", "User", const UserScreen()),

// Navigate
context.beamToNamed('/user/123');

// Access parameter in screen
final userId = context.currentBeamLocation.state.pathParameters['userId'];
```

### Deep Linking

Beamer automatically handles deep links:
- **Web**: `yourapp.com/example`
- **Mobile**: `yourapp://example` (requires platform setup)

### Clean URLs on Web

This template uses path-based URL strategy (enabled via `Beamer.setPathUrlStrategy()` in `main.dart`), which gives clean URLs without `#`:

- ✅ Good: `https://yourapp.com/profile`
- ❌ Old: `https://yourapp.com/#/profile`

## Customization

### App Icons and Splash Screen

The template includes default icons in `assets/icon/`:
- `icon.png` - 1024x1024 app icon
- `splash.png` - Splash screen image

To use your own:
1. Replace these files with your designs
2. Optionally update `pubspec.yaml` to customize splash background color:
   ```yaml
   flutter_native_splash:
     color: "#230055"  # Your color
     image: assets/icon/splash.png
   ```
3. Run generators:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

### Theme

Customize the theme in `lib/main.dart`:

```dart
ContrastedColorScheme.light(ColorSchemes.blue())  // Light theme
ContrastedColorScheme.dark(ColorSchemes.blue())   // Dark theme
```

Available color schemes: `blue`, `red`, `green`, `purple`, `orange`, etc.

**Toggle theme at runtime:**
```dart
context.toggleTheme()  // Cycles: light → dark → system
```

### Platform Versions

Use the helper scripts to configure minimum platform versions:

```bash
# Android minSDK
../scripts/set_android_min_sdk.sh my_app 23

# iOS minimum version
../scripts/set_ios_platform_version.sh my_app 13.0

# macOS minimum version
../scripts/set_macos_platform_version.sh my_app 10.15
```

See [Helper Scripts Documentation](../scripts/README.md) for details.

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run on default device
flutter run

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d macos          # macOS
flutter run -d linux          # Linux

# Build for release
flutter build web
flutter build apk
flutter build ios
flutter build macos
flutter build linux
flutter build windows

# Analyze code
flutter analyze

# Generate icons
dart run flutter_launcher_icons

# Generate splash screens
dart run flutter_native_splash:create
```

## Optional Firebase Setup

Firebase is already configured in `pubspec.yaml` but commented out. To enable:

1. Uncomment Firebase dependencies in `pubspec.yaml`
2. Run `flutter pub get`
3. Follow the Firebase setup steps in [SETUP.md](SETUP.md)

## Optional Server Setup

For server-side operations (API, server-side rendering, etc.):

1. Follow the 3-project architecture setup in [SETUP.md](SETUP.md)
2. Create the server project
3. Deploy to Google Cloud Run

## Resources

- [Arcane Documentation](https://pub.dev/packages/arcane)
- [Beamer Documentation](https://pub.dev/packages/beamer)
- [Flutter Documentation](https://flutter.dev/docs)
- [Complete Setup Guide](SETUP.md)
- [Helper Scripts](../scripts/README.md)
- [SoftwareThings Documentation](../SoftwareThings/) - Comprehensive docs for all libraries

## Architecture Guides

For detailed information about the libraries used in this template:

- **[ArcaneDesign.txt](../SoftwareThings/ArcaneDesign.txt)** - Complete Arcane UI reference
- **[Pylon.txt](../SoftwareThings/Pylon.txt)** - State management guide
- **[FireCrud.txt](../SoftwareThings/FireCrud.txt)** - Firestore operations
- **[Toxic.txt](../SoftwareThings/Toxic.txt)** - Utility extensions
- **[Artifact.txt](../SoftwareThings/Artifact.txt)** - Data serialization

## Key Differences from arcane_template

This template includes:
- ✅ **Beamer** for declarative routing
- ✅ **Deep linking** support
- ✅ **Clean URLs** on web (path-based strategy)
- ✅ **Centralized routing** in `routes.dart`

If you don't need navigation or prefer a different routing solution, use `arcane_template` instead.

## Troubleshooting

### Build Issues
- Run `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade`
- Check: `flutter doctor -v`

### Beamer Issues
- Ensure `Beamer.setPathUrlStrategy()` is before `runApp()`
- Check route patterns in `routes.dart`
- Use `context.beamToNamed()`, not `Navigator.push()`
- Verify `routerDelegate` is passed to `ArcaneApp.router()`

### Platform-Specific Issues
- **iOS**: Ensure Xcode is up to date
- **Android**: Check Android SDK installation
- **macOS**: Install CocoaPods: `sudo gem install cocoapods`
- **Web**: Use Chrome for debugging

See [SETUP.md](SETUP.md) for detailed troubleshooting.

## Support

- [GitHub Issues - Arcane](https://github.com/ArcaneArts/arcane/issues) - Arcane framework issues
- [GitHub Issues - Beamer](https://github.com/slovnicki/beamer/issues) - Beamer navigation issues
- [Flutter Community](https://flutter.dev/community) - Flutter support

## License

See [LICENSE](../LICENSE) file for details.

---

**Ready to build something amazing with Arcane + Beamer!** 🎉

Start with the [Complete Setup Guide](SETUP.md) for production apps, or use the Quick Start above for rapid prototyping.
