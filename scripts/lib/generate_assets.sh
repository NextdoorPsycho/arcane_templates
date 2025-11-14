#!/bin/bash

# Generate Assets
# Generates app icons and splash screens for all platforms

# Source utilities
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/utils.sh"

generate_launcher_icons() {
    local app_name="$1"

    log_step "Generating Launcher Icons"

    cd "$app_name" || return 1

    # Check if icon file exists
    if [ ! -f "assets/icon/icon.png" ]; then
        log_warning "Icon file not found at assets/icon/icon.png"
        log_instruction "Please add your app icon (1024x1024 PNG) at assets/icon/icon.png"
        cd ..
        return 0
    fi

    log_info "Running flutter_launcher_icons..."
    echo ""

    dart run flutter_launcher_icons

    if [ $? -ne 0 ]; then
        log_error "Failed to generate launcher icons"
        cd ..
        return 1
    fi

    cd .. || return 1

    log_success "Launcher icons generated successfully"
    return 0
}

generate_splash_screens() {
    local app_name="$1"

    log_step "Generating Splash Screens"

    cd "$app_name" || return 1

    # Check if splash file exists
    if [ ! -f "assets/icon/splash.png" ]; then
        log_warning "Splash image not found at assets/icon/splash.png"
        log_instruction "Please add your splash image at assets/icon/splash.png"
        cd ..
        return 0
    fi

    log_info "Running flutter_native_splash:create..."
    echo ""

    dart run flutter_native_splash:create

    if [ $? -ne 0 ]; then
        log_error "Failed to generate splash screens"
        cd ..
        return 1
    fi

    cd .. || return 1

    log_success "Splash screens generated successfully"
    return 0
}

configure_platform_versions() {
    local app_name="$1"

    log_step "Configuring Platform Versions"

    log_info "Setting Android minSDK to 23..."
    ./scripts/set_android_min_sdk.sh "$app_name" 23 || log_warning "Failed to set Android minSDK"

    log_info "Setting iOS deployment target to 13.0..."
    ./scripts/set_ios_platform_version.sh "$app_name" 13.0 || log_warning "Failed to set iOS version"

    log_info "Setting macOS deployment target to 10.15..."
    ./scripts/set_macos_platform_version.sh "$app_name" 10.15 || log_warning "Failed to set macOS version"

    log_success "Platform versions configured"
    return 0
}

generate_all_assets() {
    local app_name="$1"

    # Configure platform versions first
    configure_platform_versions "$app_name"

    # Generate icons
    generate_launcher_icons "$app_name"

    # Generate splash screens
    generate_splash_screens "$app_name"

    log_success "Asset generation complete"
    return 0
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <app_name>"
        echo "Example: $0 my_app"
        exit 1
    fi

    generate_all_assets "$1"
fi
