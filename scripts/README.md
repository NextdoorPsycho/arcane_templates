
# Setup Scripts & Helper Utilities

This directory contains the automated setup wizard and helper scripts for creating and configuring Flutter projects with the Arcane templates.

## 🚀 Automated Setup Wizard

**NEW!** Use the interactive setup wizard to automate the entire project creation process.

### Quick Start

From the repository root, run:

```bash
./setup.sh
```

The wizard will guide you through:
1. ✅ CLI tools verification (Flutter, Firebase, gcloud, Docker, etc.)
2. 📝 Project configuration (name, organization, template selection)
3. 🔥 Optional Firebase setup
4. 🏗️ 3-project architecture creation (client, models, server)
5. 📦 Automatic dependency installation
6. ⚙️ Firebase integration (if enabled)
7. 🎨 App icon and splash screen setup
8. 🐳 Server Dockerfile generation
9. 🚢 Optional Firebase deployment

### What the Setup Wizard Does

The `setup.sh` script orchestrates the complete setup process, replacing what the old Occult CLI tool did:

- **Creates 3 projects**: Client app, models package, and server app
- **Installs dependencies**: Automatically adds Arcane, Firebase, and all required packages
- **Configures Firebase**: Handles FlutterFire configuration, Firebase CLI setup, and config file generation
- **Generates assets**: Creates app icons and splash screens for all platforms
- **Sets platform versions**: Configures Android (SDK 23), iOS (13.0), and macOS (10.15) targets
- **Sets up server**: Creates Dockerfiles for server deployment to Google Cloud Run
- **Deploys Firebase**: Optionally deploys Firestore, Storage, and Hosting

### Library Scripts

The setup wizard uses modular scripts in `scripts/lib/`:

| Script | Purpose |
|--------|---------|
| `utils.sh` | Logging, prompts, validation functions |
| `check_tools.sh` | Verify CLI tools installation |
| `create_projects.sh` | Create client, models, and server projects |
| `add_dependencies.sh` | Install all dependencies |
| `setup_firebase.sh` | Firebase and gcloud login, FlutterFire config |
| `generate_configs.sh` | Create Firebase config files |
| `generate_assets.sh` | Generate icons and splash screens |
| `setup_server.sh` | Create Dockerfiles for server |
| `deploy_firebase.sh` | Deploy to Firebase |

### Running Individual Steps

You can also run individual setup steps:

```bash
# Check CLI tools
./scripts/lib/check_tools.sh

# Create projects only
./scripts/lib/create_projects.sh my_app art.arcane

# Add dependencies
./scripts/lib/add_dependencies.sh my_app yes  # 'yes' for Firebase

# Generate assets
./scripts/lib/generate_assets.sh my_app
```

---

## 🔧 Manual Configuration Scripts

If you prefer manual control or need to adjust specific settings after setup, use these helper scripts:

### Available Scripts

### 1. Set Android MinSDK Version

**File:** `set_android_min_sdk.sh`

Updates the Android minimum SDK version in your Flutter project.

**Usage:**
```bash
./scripts/set_android_min_sdk.sh <app_name> <min_sdk_version>
```

**Example:**
```bash
./scripts/set_android_min_sdk.sh my_app 23
```

**What it does:**
- Modifies `<app_name>/android/app/build.gradle.kts`
- Updates the `minSdk` value to your specified version
- Common values: 21 (Android 5.0), 23 (Android 6.0), 24 (Android 7.0)

---

### 2. Set iOS Platform Version

**File:** `set_ios_platform_version.sh`

Updates the iOS deployment target version in your Flutter project.

**Usage:**
```bash
./scripts/set_ios_platform_version.sh <app_name> <ios_version>
```

**Example:**
```bash
./scripts/set_ios_platform_version.sh my_app 13.0
```

**What it does:**
- Modifies `<app_name>/ios/Runner.xcodeproj/project.pbxproj`
- Updates all `IPHONEOS_DEPLOYMENT_TARGET` values to your specified version
- Common values: 12.0, 13.0, 14.0, 15.0

---

### 3. Set macOS Platform Version

**File:** `set_macos_platform_version.sh`

Updates the macOS deployment target version in your Flutter project.

**Usage:**
```bash
./scripts/set_macos_platform_version.sh <app_name> <macos_version>
```

**Example:**
```bash
./scripts/set_macos_platform_version.sh my_app 10.15
```

**What it does:**
- Modifies `<app_name>/macos/Runner.xcodeproj/project.pbxproj`
- Updates all `MACOSX_DEPLOYMENT_TARGET` values
- Modifies `<app_name>/macos/Podfile`
- Updates the `platform :osx` version
- Common values: 10.13, 10.14, 10.15, 11.0, 12.0

---

## Requirements

### All Scripts
- Bash shell (available on macOS, Linux, and Windows with Git Bash or WSL)
- Must be run from the project root directory (where your app directories are located)

### macOS-specific
- The scripts detect macOS automatically and use the appropriate `sed` command

### Linux-specific
- Uses standard GNU `sed` syntax

---

## Running Scripts

### Make Scripts Executable (First Time Only)

```bash
chmod +x scripts/*.sh
```

### Run from Project Root

All scripts must be run from your project root directory (the parent directory containing your Flutter app):

```bash
# Correct ✓
your-project-root/
├── my_app/
├── my_app_models/
├── my_app_server/
└── scripts/

# Run from here:
cd your-project-root
./scripts/set_android_min_sdk.sh my_app 23
```

**Incorrect:**
```bash
# Wrong ✗ - Don't run from inside the app directory
cd my_app
../scripts/set_android_min_sdk.sh my_app 23  # This will fail!
```

---

## Examples

### Complete Setup for New Project

After creating your projects, run all platform configuration scripts:

```bash
# Set Android minSDK to 23 (Android 6.0)
./scripts/set_android_min_sdk.sh my_app 23

# Set iOS deployment target to 13.0
./scripts/set_ios_platform_version.sh my_app 13.0

# Set macOS deployment target to 10.15 (Catalina)
./scripts/set_macos_platform_version.sh my_app 10.15
```

### Batch Update Multiple Projects

If you have multiple apps to configure:

```bash
#!/bin/bash
APPS=("my_app" "my_other_app" "my_third_app")

for app in "${APPS[@]}"; do
  echo "Configuring $app..."
  ./scripts/set_android_min_sdk.sh "$app" 23
  ./scripts/set_ios_platform_version.sh "$app" 13.0
  ./scripts/set_macos_platform_version.sh "$app" 10.15
done
```

---

## Troubleshooting

### "Permission denied" Error

Make the scripts executable:
```bash
chmod +x scripts/*.sh
```

### "File not found" Error

Ensure you're running the script from the correct directory (project root):
```bash
pwd  # Should show your project root, not the app directory
ls   # Should list your app directories
```

### Changes Not Applied

- Check that the file paths in the error messages match your project structure
- Verify your app name is correct
- Some IDEs may need to be restarted to detect changes

### macOS/Linux sed Differences

The scripts automatically detect the OS and use the appropriate `sed` syntax:
- macOS: `sed -i ''`
- Linux: `sed -i`

If you encounter issues, you may need to manually edit the script for your platform.

---

## Manual Alternative

If you prefer not to use scripts, you can manually edit the files:

### Android MinSDK
1. Open `<app_name>/android/app/build.gradle.kts`
2. Find: `minSdk = flutter.minSdkVersion` or `minSdk = <number>`
3. Change to: `minSdk = 23` (or your desired version)

### iOS Platform Version
1. Open `<app_name>/ios/Runner.xcodeproj/project.pbxproj` in a text editor
2. Find all lines: `IPHONEOS_DEPLOYMENT_TARGET = <version>;`
3. Change to: `IPHONEOS_DEPLOYMENT_TARGET = 13.0;` (or your desired version)

### macOS Platform Version
1. Open `<app_name>/macos/Runner.xcodeproj/project.pbxproj` in a text editor
2. Find all lines: `MACOSX_DEPLOYMENT_TARGET = <version>;`
3. Change to: `MACOSX_DEPLOYMENT_TARGET = 10.15;` (or your desired version)
4. Open `<app_name>/macos/Podfile`
5. Find: `platform :osx, '<version>'`
6. Change to: `platform :osx, '10.15'` (or your desired version)

---

## Contributing

If you create additional helper scripts, please:
1. Follow the same naming convention: `set_<platform>_<configuration>.sh`
2. Include usage instructions in the script header
3. Add error handling for missing files
4. Update this README with documentation
5. Make the script cross-platform compatible (macOS/Linux)

---

## Recommended Platform Versions

Based on the Occult automation tool defaults:

| Platform | Minimum Version | Reason |
|----------|----------------|--------|
| Android | 23 (Android 6.0) | Good balance of features and device coverage |
| iOS | 13.0 | Required for many modern Flutter plugins |
| macOS | 10.15 (Catalina) | Supports latest Flutter desktop features |

You can adjust these based on your target audience and required features.
