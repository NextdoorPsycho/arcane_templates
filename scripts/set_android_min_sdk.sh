#!/bin/bash

# Script to set Android minSDK version
# Usage: ./set_android_min_sdk.sh <app_name> <min_sdk_version>

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <app_name> <min_sdk_version>"
    echo "Example: $0 my_app 23"
    exit 1
fi

APP_NAME="$1"
MIN_SDK="$2"
BUILD_GRADLE="$APP_NAME/android/app/build.gradle.kts"

if [ ! -f "$BUILD_GRADLE" ]; then
    echo "Error: File not found: $BUILD_GRADLE"
    echo "Make sure you run this script from the project root directory."
    exit 1
fi

echo "Updating Android minSDK version to $MIN_SDK in $APP_NAME..."

# Use sed to replace the minSdk line
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version of sed
    sed -i '' "s/minSdk = [0-9]*/minSdk = $MIN_SDK/" "$BUILD_GRADLE"
else
    # Linux version of sed
    sed -i "s/minSdk = [0-9]*/minSdk = $MIN_SDK/" "$BUILD_GRADLE"
fi

echo "✓ Successfully updated Android minSDK to $MIN_SDK"
echo "  File: $BUILD_GRADLE"
