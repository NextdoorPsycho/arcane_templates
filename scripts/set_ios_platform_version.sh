#!/bin/bash

# Script to set iOS platform version
# Usage: ./set_ios_platform_version.sh <app_name> <ios_version>

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <app_name> <ios_version>"
    echo "Example: $0 my_app 13.0"
    exit 1
fi

APP_NAME="$1"
IOS_VERSION="$2"
PBXPROJ="$APP_NAME/ios/Runner.xcodeproj/project.pbxproj"

if [ ! -f "$PBXPROJ" ]; then
    echo "Error: File not found: $PBXPROJ"
    echo "Make sure you run this script from the project root directory."
    exit 1
fi

echo "Updating iOS deployment target to $IOS_VERSION in $APP_NAME..."

# Use sed to replace IPHONEOS_DEPLOYMENT_TARGET lines
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version of sed
    sed -i '' "s/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*;/IPHONEOS_DEPLOYMENT_TARGET = $IOS_VERSION;/" "$PBXPROJ"
else
    # Linux version of sed
    sed -i "s/IPHONEOS_DEPLOYMENT_TARGET = [0-9.]*;/IPHONEOS_DEPLOYMENT_TARGET = $IOS_VERSION;/" "$PBXPROJ"
fi

echo "✓ Successfully updated iOS deployment target to $IOS_VERSION"
echo "  File: $PBXPROJ"
