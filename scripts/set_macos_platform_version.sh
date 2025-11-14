#!/bin/bash

# Script to set macOS platform version
# Usage: ./set_macos_platform_version.sh <app_name> <macos_version>

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <app_name> <macos_version>"
    echo "Example: $0 my_app 10.15"
    exit 1
fi

APP_NAME="$1"
MACOS_VERSION="$2"
PBXPROJ="$APP_NAME/macos/Runner.xcodeproj/project.pbxproj"
PODFILE="$APP_NAME/macos/Podfile"

if [ ! -f "$PBXPROJ" ]; then
    echo "Error: File not found: $PBXPROJ"
    echo "Make sure you run this script from the project root directory."
    exit 1
fi

if [ ! -f "$PODFILE" ]; then
    echo "Error: File not found: $PODFILE"
    echo "Make sure you run this script from the project root directory."
    exit 1
fi

echo "Updating macOS deployment target to $MACOS_VERSION in $APP_NAME..."

# Update Xcode project file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version of sed
    sed -i '' "s/MACOSX_DEPLOYMENT_TARGET = [0-9.]*;/MACOSX_DEPLOYMENT_TARGET = $MACOS_VERSION;/" "$PBXPROJ"
else
    # Linux version of sed
    sed -i "s/MACOSX_DEPLOYMENT_TARGET = [0-9.]*;/MACOSX_DEPLOYMENT_TARGET = $MACOS_VERSION;/" "$PBXPROJ"
fi

echo "✓ Successfully updated macOS deployment target in Xcode project"
echo "  File: $PBXPROJ"

# Update Podfile
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version of sed
    sed -i '' "s/platform :osx, '[0-9.]*'/platform :osx, '$MACOS_VERSION'/" "$PODFILE"
else
    # Linux version of sed
    sed -i "s/platform :osx, '[0-9.]*'/platform :osx, '$MACOS_VERSION'/" "$PODFILE"
fi

echo "✓ Successfully updated macOS deployment target in Podfile"
echo "  File: $PODFILE"

echo ""
echo "All done! macOS deployment target set to $MACOS_VERSION"
