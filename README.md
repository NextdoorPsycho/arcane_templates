# Arcane Templates

Complete Flutter project templates using the Arcane UI framework - Material Design-free UI with pure Arcane components.

## 🚀 Quick Start - Automated Setup

**New!** Use the interactive setup wizard to create your complete project in minutes:

```bash
./setup.sh
```

The wizard automates everything:
- ✅ CLI tools verification
- 🏗️ 3-project architecture creation (client, models, server)
- 📦 Dependency installation
- 🔥 Firebase integration (optional)
- 🎨 App icons and splash screens
- 🐳 Server Docker setup
- 🚢 Firebase deployment (optional)

**This replaces the old Occult CLI tool!** Everything Occult did is now automated with shell scripts.

[📖 Read Setup Script Documentation](scripts/README.md)

---

## 📦 Available Templates

### 1. arcane_template
**Pure Arcane UI without navigation framework**

- Material Design-free components
- Multi-platform support (Web, iOS, Android, Linux, macOS, Windows)
- Theme management (light/dark/system)
- Firebase ready (optional)
- Server deployment ready

[View Template](arcane_template/) | [Setup Guide](arcane_template/SETUP.md)

### 2. arcane_beamer
**Arcane UI + Beamer Navigation**

- Everything in arcane_template, plus:
- Declarative routing with Beamer
- Deep linking support
- Clean URLs on web (path-based strategy)
- Centralized route management

[View Template](arcane_beamer/) | [Setup Guide](arcane_beamer/SETUP.md)

---

## 🎯 What's Included

### UI Framework
- **Arcane Components**: Screen, Bar, Collection, Section, Tile, Card, Gap, Buttons
- **Arcane Extensions**: arcane_fluf, arcane_auth, arcane_user
- **Theme System**: Built-in light/dark/system theme toggle

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

---

## 🔧 Two Ways to Get Started

### Option 1: Automated Setup (Recommended)

Run the interactive wizard:

```bash
./setup.sh
```

Choose your options:
- Template selection (arcane_template or arcane_beamer)
- Organization domain (e.g., com.mycompany)
- App name (e.g., my_awesome_app)
- Firebase integration (yes/no)
- Google Cloud Run deployment (yes/no)

The wizard handles everything automatically!

### Option 2: Manual Setup

Follow the comprehensive guides in each template:

- **[arcane_template Setup Guide](arcane_template/SETUP.md)** - Step-by-step manual setup
- **[arcane_beamer Setup Guide](arcane_beamer/SETUP.md)** - With Beamer navigation

---

## 📁 Project Architecture

Both templates support a 3-project architecture:

```
your-project-root/
├── your_app/              # Main Flutter client application
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── macos/
│   ├── linux/
│   └── windows/
│
├── your_app_models/       # Shared Dart package for data models
│   └── lib/
│       └── models/
│
├── your_app_server/       # Flutter server application
│   ├── lib/
│   │   └── server/
│   ├── Dockerfile
│   └── Dockerfile-dev
│
└── config/                # Configuration files
    ├── keys/              # Service account keys (gitignored)
    ├── firebase.json      # Firebase configuration
    ├── firestore.rules
    └── storage.rules
```

**Benefits:**
- ✅ Separation of concerns
- ✅ Code sharing between client and server
- ✅ Type-safe data models
- ✅ Independent deployment

---

## ⚡ Features

### 🎨 Pure Arcane UI
- No Material Design components
- Consistent design language
- Highly customizable theming
- Beautiful out-of-the-box

### 🔥 Firebase Integration (Optional)
- Authentication (Email, Google, Apple)
- Cloud Firestore database
- Cloud Storage
- Analytics & Crashlytics
- Firebase Hosting
- Pre-configured security rules

### 🌐 Multi-Platform Support
- **Web**: Clean URLs with Beamer (arcane_beamer only)
- **Mobile**: iOS and Android
- **Desktop**: Windows, macOS, Linux

### 🚢 Server Deployment
- Docker containerization
- Google Cloud Run ready
- Service account integration
- Automatic Dockerfile generation

### 🎯 Developer Experience
- Hot reload
- Fast build times
- Type-safe architecture
- Comprehensive documentation

---

## 🛠️ Helper Scripts

Automated scripts for common tasks:

```bash
# Set Android minSDK
./scripts/set_android_min_sdk.sh my_app 23

# Set iOS deployment target
./scripts/set_ios_platform_version.sh my_app 13.0

# Set macOS deployment target
./scripts/set_macos_platform_version.sh my_app 10.15
```

[View All Helper Scripts](scripts/README.md)

---

## 📚 Documentation

### Setup Guides
- **[Automated Setup Script](scripts/README.md)** - Interactive wizard documentation
- **[arcane_template Setup](arcane_template/SETUP.md)** - Manual setup for basic template
- **[arcane_beamer Setup](arcane_beamer/SETUP.md)** - Manual setup with Beamer navigation

### Library Documentation
Comprehensive guides for all included libraries in `SoftwareThings/`:

- **[ArcaneDesign.txt](SoftwareThings/ArcaneDesign.txt)** - Complete Arcane UI reference
- **[Pylon.txt](SoftwareThings/Pylon.txt)** - State management guide
- **[FireCrud.txt](SoftwareThings/FireCrud.txt)** - Firestore operations
- **[Toxic.txt](SoftwareThings/Toxic.txt)** - Utility extensions
- **[Artifact.txt](SoftwareThings/Artifact.txt)** - Data serialization
- **[ArcaneDesktop.txt](SoftwareThings/ArcaneDesktop.txt)** - Desktop features

---

## 🎓 Prerequisites

### Required
- Flutter SDK
- Dart SDK (included with Flutter)

### Optional (Based on Features)
- Firebase CLI (for Firebase integration)
- FlutterFire CLI (for Firebase)
- Google Cloud CLI (for server deployment)
- Docker (for containerization)
- npm (for Firebase CLI)

### macOS Only
- Homebrew
- CocoaPods (for iOS/macOS)

**The setup wizard checks all prerequisites for you!**

---

## 🚀 Quick Example

After running `./setup.sh`:

```bash
# Run your app
cd my_app
flutter run

# Build for web
flutter build web --release

# Generate new icons
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# Deploy to Firebase
cd ..
firebase deploy --only hosting
```

---

## 🌟 What Makes This Different?

### vs. Flutter Templates
- ✅ No Material Design dependency
- ✅ Production-ready architecture
- ✅ Firebase pre-configured
- ✅ Server included
- ✅ Complete automation

### vs. Occult CLI
- ✅ No Dart installation needed (pure Bash)
- ✅ Modular, understandable scripts
- ✅ Easy to customize and extend
- ✅ Better error handling
- ✅ Cross-platform (macOS/Linux)

---

## 🔄 Migration from Occult

If you previously used the Occult CLI tool:

**Old way:**
```bash
dart pub global activate occult
occult create
```

**New way:**
```bash
./setup.sh
```

All Occult functionality is now built into the shell scripts!

---

## 🤝 Contributing

Improvements welcome! To add features:

1. Fork the repository
2. Create your feature branch
3. Add scripts to `scripts/lib/`
4. Update documentation
5. Test on macOS and Linux
6. Submit a pull request

---

## 📝 License

See [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Arcane Framework** - [ArcaneArts/arcane](https://github.com/ArcaneArts/arcane)
- **Beamer Navigation** - [slovnicki/beamer](https://github.com/slovnicki/beamer)
- **Flutter Team** - [flutter.dev](https://flutter.dev)

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/ArcaneArts/arcane/issues)
- **Flutter Community**: [flutter.dev/community](https://flutter.dev/community)
- **Arcane Discord**: Ask in the Arcane community

---

**Ready to build something amazing with Arcane?** 🚀

```bash
./setup.sh
```

Choose your template, configure your project, and let the wizard do the rest!
