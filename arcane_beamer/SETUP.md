# Arcane + Beamer Template Setup Guide

This guide will walk you through setting up a complete Flutter application with the Arcane UI framework and Beamer navigation, following a 3-project architecture (client app, shared models, and server).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure Overview](#project-structure-overview)
- [Step-by-Step Setup](#step-by-step-setup)
  - [1. Create Firebase Project (Optional)](#1-create-firebase-project-optional)
  - [2. Create Google Cloud Service Account (Optional - Firebase)](#2-create-google-cloud-service-account-optional---firebase)
  - [3. Create Artifact Registry (Optional - Server Deployment)](#3-create-artifact-registry-optional---server-deployment)
  - [4. Configure Project Settings](#4-configure-project-settings)
  - [5. Create Projects](#5-create-projects)
  - [6. Setup Dependencies](#6-setup-dependencies)
  - [7. Configure Firebase (Optional)](#7-configure-firebase-optional)
  - [8. Configure Platform Versions](#8-configure-platform-versions)
  - [9. Generate App Icons and Splash Screen](#9-generate-app-icons-and-splash-screen)
  - [10. Deploy Firebase Resources (Optional)](#10-deploy-firebase-resources-optional)
  - [11. Setup Server Deployment (Optional)](#11-setup-server-deployment-optional)
- [Quick Start (Minimal Setup)](#quick-start-minimal-setup)
- [Beamer Navigation Setup](#beamer-navigation-setup)
- [Helper Scripts](#helper-scripts)

---

## Prerequisites

Before starting, ensure you have the following CLI tools installed:

### Required Tools
- **Flutter SDK** - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** - Included with Flutter

### Optional Tools (Based on Features)
- **Firebase CLI** - Required for Firebase integration: `npm install -g firebase-tools`
- **FlutterFire CLI** - Required for Firebase: `dart pub global activate flutterfire_cli`
- **Google Cloud CLI (gcloud)** - Required for server deployment: [Install gcloud](https://cloud.google.com/sdk/docs/install)
- **Docker** - Required for server containerization: [Install Docker](https://docs.docker.com/get-docker/)
- **npm** - Required for Firebase CLI

### macOS Only (for iOS/macOS development)
- **Homebrew** - [Install Homebrew](https://brew.sh/)
- **CocoaPods** - `sudo gem install cocoapods`

### Verify Installation

```bash
# Required
flutter --version
dart --version

# Optional (if using these features)
firebase --version
flutterfire --version
gcloud --version
docker --version
npm --version

# macOS only
brew --version
pod --version
```

---

## Project Structure Overview

This template uses a 3-project architecture with Beamer for declarative routing:

```
your-project-root/
├── your_app/              # Main Flutter client application with Beamer
│   ├── lib/
│   │   ├── main.dart           # App entry with Beamer setup
│   │   ├── routes.dart         # Beamer route definitions
│   │   ├── screens/            # Screen widgets
│   │   │   ├── home_screen.dart
│   │   │   ├── example_screen.dart
│   │   │   └── not_found_screen.dart
│   │   └── service/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── macos/
│   ├── linux/
│   ├── windows/
│   └── pubspec.yaml
│
├── your_app_models/       # Shared Dart package for data models
│   ├── lib/
│   │   ├── your_app_models.dart
│   │   └── models/
│   │       └── user/
│   └── pubspec.yaml
│
├── your_app_server/       # Flutter server application
│   ├── lib/
│   │   ├── main.dart
│   │   └── server/
│   │       ├── api/
│   │       ├── service/
│   │       └── util/
│   ├── Dockerfile
│   ├── Dockerfile-dev
│   └── pubspec.yaml
│
└── config/                # Configuration files
    ├── keys/              # Service account keys (gitignored)
    ├── firebase.json      # Firebase configuration (optional)
    ├── firestore.rules    # Firestore security rules (optional)
    ├── firestore.indexes.json
    └── storage.rules      # Storage security rules (optional)
```

**Key differences from arcane_template:**
- **Beamer integration**: Declarative routing with deep linking support
- **Path-based URLs**: Clean URLs without # on web (e.g., `/profile` instead of `/#/profile`)
- **Route definitions**: Centralized in `routes.dart` using BeamerDelegate

---

## Step-by-Step Setup

### 1. Create Firebase Project (Optional)

**Skip this section if you don't need Firebase integration.**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter a project name (e.g., `my-awesome-app`)
4. Note your **Firebase Project ID** (visible in the console URL: `https://console.firebase.google.com/project/YOUR-PROJECT-ID`)

**Enable Firestore Database:**

1. Navigate to [Firestore Database](https://console.firebase.google.com/project/YOUR-PROJECT-ID/firestore)
2. Click "Create database"
3. Choose production mode or test mode
4. Select a location (e.g., `nam5` for US-based projects)

**Setup Authentication:**

1. Go to [Authentication](https://console.firebase.google.com/project/YOUR-PROJECT-ID/authentication)
2. Click "Get started"
3. Enable auth providers you need:
   - Email/Password (optional)
   - Google (optional, requires additional setup)
   - Apple (optional, requires additional setup, iOS/macOS only)

**Enable Billing:**

Some features require upgrading to the "Blaze" (pay-as-you-go) plan:

1. Go to "Project settings" > "Usage and billing"
2. Click "Modify plan" and upgrade to Blaze plan

---

### 2. Create Google Cloud Service Account (Optional - Firebase)

**Skip this section if you're not using Firebase or server deployment.**

This service account is required for server-side Firebase operations.

1. Go to [Google Cloud Console - Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts/create?hl=en&project=YOUR-PROJECT-ID)
2. Fill in the details:
   - **Service account name**: `your-project-server`
   - **Service account ID**: `your-project-server`
3. Click "Create and Continue"
4. **Add role**: Select "Basic" > "Owner"
5. Click "Continue" then "Done"
6. In the service accounts list, click on `your-project-server@your-project-id.iam.gserviceaccount.com`
7. Go to the "KEYS" tab
8. Click "ADD KEY" > "Create new key" > "JSON"
9. Save the downloaded JSON file as `config/keys/your-project-id-server-<hash>.json`

**Create the keys directory:**

```bash
mkdir -p config/keys
# Move the downloaded JSON file here
mv ~/Downloads/your-project-id-*.json config/keys/
```

---

### 3. Create Artifact Registry (Optional - Server Deployment)

**Skip this section if you're not deploying a server to Google Cloud Run.**

This registry stores Docker images for your server deployments.

1. Go to [Artifact Registry](https://console.cloud.google.com/artifacts/create-repo?project=YOUR-PROJECT-ID&hl=en)
2. Configure the repository:
   - **Name**: `cloud-run-source-deploy`
   - **Format**: Docker
   - **Mode**: Standard
   - **Location**: Region
   - **Region**: `us-central1` (Iowa)
   - **Encryption**: Google-managed key
   - **Immutable image tags**: Disabled
3. Click "ADD A CLEANUP POLICY":
   - **Name**: `Autoclean`
   - **Policy Type**: Keep most recent versions
   - **Keep Count**: `2`
   - Click "Done"
4. Click "ADD ANOTHER CLEANUP POLICY":
   - **Name**: `Autodelete`
   - **Policy Type**: Conditional Delete
   - **Tag State**: Any Tag State
   - Click "Done"
5. Click "CREATE REPOSITORY"

**Enable required Google APIs:**

```bash
gcloud config set project YOUR-PROJECT-ID
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
```

---

### 4. Configure Project Settings

Decide on your project naming:

- **Organization domain**: e.g., `art.arcane`, `com.mycompany`
- **App name**: lowercase with underscores, e.g., `my_awesome_app`
- **Base class name**: UpperCamelCase, e.g., `MyAwesomeApp`

---

### 5. Create Projects

Navigate to your project root directory (where you want to create the 3 projects).

#### Create Client App

```bash
flutter create \
  --platforms=android,ios,web,linux,windows,macos \
  -a java \
  -t app \
  --suppress-analytics \
  -e \
  --org YOUR_ORG_DOMAIN \
  --project-name YOUR_APP_NAME \
  YOUR_APP_NAME
```

**Example:**
```bash
flutter create \
  --platforms=android,ios,web,linux,windows,macos \
  -a java \
  -t app \
  --suppress-analytics \
  -e \
  --org art.arcane \
  --project-name my_app \
  my_app
```

#### Create Models Package

```bash
flutter create \
  -t package \
  --suppress-analytics \
  --project-name YOUR_APP_NAME_models \
  YOUR_APP_NAME_models
```

**Example:**
```bash
flutter create \
  -t package \
  --suppress-analytics \
  --project-name my_app_models \
  my_app_models
```

#### Create Server App

```bash
flutter create \
  --platforms=linux \
  -t app \
  --suppress-analytics \
  -e \
  --org YOUR_ORG_DOMAIN \
  --project-name YOUR_APP_NAME_server \
  YOUR_APP_NAME_server
```

**Example:**
```bash
flutter create \
  --platforms=linux \
  -t app \
  --suppress-analytics \
  -e \
  --org art.arcane \
  --project-name my_app_server \
  my_app_server
```

---

### 6. Setup Dependencies

#### Client App Dependencies

Navigate to your client app directory:

```bash
cd YOUR_APP_NAME
```

**Add main dependencies:**

```bash
flutter pub add \
  arcane \
  arcane_fluf \
  arcane_auth \
  arcane_user \
  toxic \
  toxic_flutter \
  pylon \
  rxdart \
  beamer \
  hive \
  hive_flutter \
  flutter_native_splash \
  serviced \
  fast_log \
  http \
  convert \
  universal_io \
  intl \
  duration \
  decimal \
  rational \
  timeago \
  crypto \
  tinycolor2 \
  url_launcher \
  email_validator \
  tryhard \
  throttled \
  cached_network_image \
  faker \
  artifact
```

**Add Firebase dependencies (Optional):**

```bash
flutter pub add \
  firebase_core \
  firebase_auth \
  cloud_firestore \
  firebase_analytics \
  firebase_crashlytics \
  firebase_performance \
  firebase_storage \
  fire_crud \
  fire_api \
  fire_api_flutter \
  google_sign_in
```

**Add dev dependencies:**

```bash
flutter pub add --dev flutter_launcher_icons
```

**Add models package as path dependency:**

Edit `YOUR_APP_NAME/pubspec.yaml` and add under `dependencies`:

```yaml
dependencies:
  # ... other dependencies

  YOUR_APP_NAME_models:
    path: ../YOUR_APP_NAME_models
```

**Get dependencies:**

```bash
flutter pub get
```

#### Models Package Dependencies

Navigate to your models package directory:

```bash
cd ../YOUR_APP_NAME_models
```

**Add dependencies:**

```bash
flutter pub add \
  crypto \
  dart_mappable \
  equatable \
  fire_crud \
  toxic \
  rxdart \
  fast_log \
  jiffy \
  throttled
```

**Add Firebase dependencies (Optional):**

```bash
flutter pub add fire_api
```

**Add dev dependencies:**

```bash
flutter pub add --dev build_runner dart_mappable_builder
```

**Get dependencies:**

```bash
flutter pub get
```

#### Server App Dependencies

Navigate to your server app directory:

```bash
cd ../YOUR_APP_NAME_server
```

**Add main dependencies:**

```bash
flutter pub add \
  fire_crud \
  shelf \
  shelf_router \
  shelf_cors_headers \
  precision_stopwatch \
  google_cloud \
  http \
  toxic \
  memcached \
  fast_log \
  uuid \
  rxdart \
  crypto \
  dart_jsonwebtoken \
  x509 \
  jiffy
```

**Add Firebase dependencies (Optional):**

```bash
flutter pub add fire_api fire_api_dart
```

**Add models package as path dependency:**

Edit `YOUR_APP_NAME_server/pubspec.yaml` and add under `dependencies`:

```yaml
dependencies:
  # ... other dependencies

  YOUR_APP_NAME_models:
    path: ../YOUR_APP_NAME_models
```

**Get dependencies:**

```bash
flutter pub get
```

---

### 7. Configure Firebase (Optional)

**Skip this section if you're not using Firebase.**

Navigate to your client app directory:

```bash
cd ../YOUR_APP_NAME
```

**Login to Firebase:**

```bash
firebase login
```

**Login to Google Cloud:**

```bash
gcloud auth login
```

**Initialize FlutterFire:**

```bash
flutterfire configure \
  --project YOUR_FIREBASE_PROJECT_ID \
  --platforms android,ios,macos,web,linux,windows
```

This will:
- Create `lib/firebase_options.dart` in your app
- Register your app with Firebase for all platforms
- Configure platform-specific Firebase settings

**Create Firebase configuration files:**

Create `firebase.json` in your project root:

```json
{
  "firestore": {
    "rules": "config/firestore.rules",
    "indexes": "config/firestore.indexes.json"
  },
  "storage": {
    "rules": "config/storage.rules"
  },
  "hosting": [
    {
      "public": "YOUR_APP_NAME/build/web",
      "target": "release",
      "ignore": [
        "firebase.json",
        "**/.*",
        "**/node_modules/**"
      ],
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    },
    {
      "public": "YOUR_APP_NAME/build/web",
      "target": "beta",
      "ignore": [
        "firebase.json",
        "**/.*",
        "**/node_modules/**"
      ],
      "rewrites": [
        {
          "source": "**",
          "destination": "/index.html"
        }
      ]
    }
  ]
}
```

Create `.firebaserc` in your project root:

```json
{
  "projects": {
    "default": "YOUR_FIREBASE_PROJECT_ID"
  },
  "targets": {
    "YOUR_FIREBASE_PROJECT_ID": {
      "hosting": {
        "release": [
          "YOUR_FIREBASE_PROJECT_ID"
        ],
        "beta": [
          "YOUR_FIREBASE_PROJECT_ID-beta"
        ]
      }
    }
  }
}
```

**Create Firestore rules (`config/firestore.rules`):**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Default rule - customize as needed
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Create Firestore indexes (`config/firestore.indexes.json`):**

```json
{
  "indexes": [],
  "fieldOverrides": []
}
```

**Create Storage rules (`config/storage.rules`):**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

### 8. Configure Platform Versions

#### Android Minimum SDK

Edit `YOUR_APP_NAME/android/app/build.gradle.kts`:

Find the line:
```kotlin
minSdk = flutter.minSdkVersion
```

Change it to:
```kotlin
minSdk = 23
```

**Or use the helper script** (see [Helper Scripts](#helper-scripts))

#### iOS Platform Version

Edit `YOUR_APP_NAME/ios/Runner.xcodeproj/project.pbxproj`:

Find all lines starting with:
```
IPHONEOS_DEPLOYMENT_TARGET =
```

Change them to:
```
IPHONEOS_DEPLOYMENT_TARGET = 13.0;
```

**Or use the helper script** (see [Helper Scripts](#helper-scripts))

#### macOS Platform Version

**Edit Xcode project:**

Edit `YOUR_APP_NAME/macos/Runner.xcodeproj/project.pbxproj`:

Find all lines starting with:
```
MACOSX_DEPLOYMENT_TARGET =
```

Change them to:
```
MACOSX_DEPLOYMENT_TARGET = 10.15;
```

**Edit Podfile:**

Edit `YOUR_APP_NAME/macos/Podfile`:

Find the line:
```ruby
platform :osx, '10.14'
```

Change it to:
```ruby
platform :osx, '10.15'
```

**Or use the helper script** (see [Helper Scripts](#helper-scripts))

---

### 9. Generate App Icons and Splash Screen

#### Setup Icons and Splash Assets

This template already includes default icons and splash screens in `assets/icon/`:
- `assets/icon/icon.png` - 1024x1024 app icon
- `assets/icon/splash.png` - Splash screen image

**To use your own icons:**

1. Replace `assets/icon/icon.png` with your app icon (1024x1024 PNG)
2. Replace `assets/icon/splash.png` with your splash screen image
3. Optionally, customize the splash background color in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#230055"  # Change this to your preferred background color
  image: assets/icon/splash.png
```

#### Generate Launcher Icons

Navigate to your client app directory:

```bash
cd YOUR_APP_NAME
```

Run the icon generator:

```bash
dart run flutter_launcher_icons
```

This will generate icons for all platforms (iOS, Android, Web, Windows, macOS).

#### Generate Native Splash Screens

Run the splash screen generator:

```bash
dart run flutter_native_splash:create
```

This will generate native splash screens for all platforms.

---

### 10. Deploy Firebase Resources (Optional)

**Skip this section if you're not using Firebase.**

From your project root directory:

**Deploy Firestore rules and indexes:**

```bash
firebase deploy --only firestore
```

**Deploy Storage rules:**

```bash
firebase deploy --only storage
```

**Deploy web app to Firebase Hosting (production):**

First, build your web app:

```bash
cd YOUR_APP_NAME
flutter build web --release
cd ..
```

Then deploy:

```bash
firebase deploy --only hosting:release
```

**Setup beta hosting site:**

1. Go to [Firebase Hosting](https://console.firebase.google.com/project/YOUR-PROJECT-ID/hosting/sites)
2. Scroll to the bottom and click "Add another site"
3. Enter site ID: `YOUR-PROJECT-ID-beta`
4. Click "Add site"

**Deploy to beta:**

```bash
firebase deploy --only hosting:beta
```

---

### 11. Setup Server Deployment (Optional)

**Skip this section if you're not using a server.**

#### Create Dockerfile

Create `YOUR_APP_NAME_server/Dockerfile`:

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Setup Flutter
RUN flutter config --no-analytics
RUN flutter precache --linux

# Copy app
WORKDIR /app
COPY . .

# Get dependencies and build
RUN flutter pub get
RUN flutter build linux --release

# Expose port
EXPOSE 8080

# Run server
CMD ["/app/build/linux/x64/release/bundle/YOUR_APP_NAME_server"]
```

#### Create Development Dockerfile

Create `YOUR_APP_NAME_server/Dockerfile-dev`:

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Setup Flutter
RUN flutter config --no-analytics
RUN flutter precache --linux

# Copy app
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Expose port
EXPOSE 8080

# Run server in debug mode
CMD ["flutter", "run", "--release", "-d", "linux-server"]
```

#### Copy Service Account Key

Copy the service account JSON file to your server directory:

```bash
cp config/keys/YOUR-PROJECT-ID-*.json YOUR_APP_NAME_server/
```

Make sure to add this to `.gitignore`!

#### Build and Deploy

**Build Docker image:**

```bash
cd YOUR_APP_NAME_server

docker build -t YOUR_APP_NAME_server .
```

**Run locally for testing:**

```bash
docker run -p 8080:8080 YOUR_APP_NAME_server
```

**Deploy to Google Cloud Run:**

```bash
# Set project
gcloud config set project YOUR-PROJECT-ID

# Build and push to Artifact Registry
gcloud builds submit --tag us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloud-run-source-deploy/YOUR_APP_NAME_server

# Deploy to Cloud Run
gcloud run deploy YOUR_APP_NAME_server \
  --image us-central1-docker.pkg.dev/YOUR-PROJECT-ID/cloud-run-source-deploy/YOUR_APP_NAME_server \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars GOOGLE_APPLICATION_CREDENTIALS=/app/YOUR-PROJECT-ID-*.json
```

---

## Quick Start (Minimal Setup)

If you just want to get started quickly without Firebase or server:

```bash
# 1. Create client app
flutter create \
  --platforms=android,ios,web,linux,windows,macos \
  --org art.arcane \
  --project-name my_app \
  my_app

# 2. Add Arcane and Beamer dependencies
cd my_app
flutter pub add arcane toxic toxic_flutter pylon rxdart beamer hive hive_flutter

# 3. Copy route configuration from arcane_beamer template
# Copy lib/routes.dart and lib/main.dart from the template

# 4. Generate icons and splash
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# 5. Run the app
flutter run
```

---

## Beamer Navigation Setup

Beamer provides declarative routing with deep linking support. Here's how it's configured in this template:

### Main App Setup

In `lib/main.dart`:

```dart
import 'package:beamer/beamer.dart';
import 'package:arcane/arcane.dart';
import 'routes.dart';

void main() {
  // Enable path-based URLs for web (no # in URLs)
  Beamer.setPathUrlStrategy();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ArcaneApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate, // Defined in routes.dart
      // ... theme configuration
    );
  }
}
```

### Route Configuration

In `lib/routes.dart`:

```dart
import 'package:beamer/beamer.dart';
import 'screens/home_screen.dart';
import 'screens/example_screen.dart';
import 'screens/not_found_screen.dart';

// Global context for programmatic navigation
BuildContext? globalContext;

// Central router delegate
final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': route("/", "Home", const HomeScreen()),
      '/example': route("/example", "Example", const ExampleScreen()),
    },
  ),
  notFoundRedirectNamed: "/404",
);

// Helper to create BeamPages
MapEntry<Pattern, BeamerRouteBuilder> route(
  String path,
  String title,
  Widget screen,
) {
  return MapEntry(
    path,
    (context, state, data) {
      globalContext = context;
      return BeamPage(
        key: ValueKey('$path-${state.pathParameters}'),
        title: title,
        child: screen,
      );
    },
  );
}
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

**Get current route:**

```dart
final currentPath = context.currentBeamLocation.state.uri.path;
```

### Adding New Routes

To add a new screen:

1. Create your screen file in `lib/screens/`
2. Add route in `lib/routes.dart`:

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

### Route Parameters

**Define parameterized route:**

```dart
'/user/:userId': route("/user/:userId", "User Profile", const UserScreen()),
```

**Access parameters in screen:**

```dart
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.currentBeamLocation.state.pathParameters['userId'];
    // Use userId...
  }
}
```

### Deep Linking

Beamer automatically handles deep links on all platforms. Users can:
- Open `yourapp.com/example` directly on web
- Navigate via custom URL schemes on mobile: `yourapp://example`

### Web Configuration

For clean URLs on web (no `#`), the template already includes:

1. `Beamer.setPathUrlStrategy()` in `main.dart`
2. Firebase hosting rewrite rules in `firebase.json` (if using Firebase)

---

## Helper Scripts

To make platform version configuration easier, you can use the included helper scripts.

### Update Android MinSDK

**Location:** `scripts/set_android_min_sdk.sh`

```bash
./scripts/set_android_min_sdk.sh YOUR_APP_NAME 23
```

### Update iOS Platform Version

**Location:** `scripts/set_ios_platform_version.sh`

```bash
./scripts/set_ios_platform_version.sh YOUR_APP_NAME 13.0
```

### Update macOS Platform Version

**Location:** `scripts/set_macos_platform_version.sh`

```bash
./scripts/set_macos_platform_version.sh YOUR_APP_NAME 10.15
```

See the [Helper Scripts](#helper-scripts) section for script implementations.

---

## Next Steps

After setup:

1. Copy template code from `arcane_beamer/lib/` to your app
2. Customize screens in `lib/screens/`
3. Add routes in `lib/routes.dart`
4. Add your custom models to `YOUR_APP_NAME_models/lib/models/`
5. Implement server API endpoints in `YOUR_APP_NAME_server/lib/server/api/`
6. Configure authentication providers in Firebase (if using Firebase)
7. Test navigation and deep linking on multiple platforms
8. Deploy to app stores and hosting

---

## Troubleshooting

### Flutter build issues

- Run `flutter clean` and `flutter pub get`
- Update Flutter: `flutter upgrade`
- Check Flutter doctor: `flutter doctor -v`

### Beamer navigation issues

- Ensure `Beamer.setPathUrlStrategy()` is called before `runApp()`
- Check route patterns match your navigation calls
- Use `context.beamToNamed()` not `Navigator.push()`
- Verify `routerDelegate` is passed to `ArcaneApp.router()`

### Firebase configuration issues

- Ensure Firebase CLI is up to date: `npm install -g firebase-tools`
- Re-run `flutterfire configure` if you added new platforms
- Check that `firebase.json` and `.firebaserc` are in the project root
- For web deep linking, ensure rewrites are configured in `firebase.json`

### Server deployment issues

- Ensure Docker is running: `docker ps`
- Check Google Cloud authentication: `gcloud auth list`
- Verify project is set: `gcloud config get-value project`
- Check Cloud Run logs: `gcloud run logs read YOUR_APP_NAME_server --region us-central1`

---

## Resources

- [Arcane Documentation](https://pub.dev/packages/arcane)
- [Beamer Documentation](https://pub.dev/packages/beamer)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)

---

**Happy coding with Arcane + Beamer! 🎉**
