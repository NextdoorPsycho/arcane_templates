#!/bin/bash

# Setup Firebase
# Handles Firebase CLI login and FlutterFire configuration

# Source utilities
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/utils.sh"

firebase_login() {
    log_step "Firebase Login"

    if ! command_exists "firebase"; then
        log_error "Firebase CLI is not installed"
        log_instruction "Install it with: npm install -g firebase-tools"
        return 1
    fi

    log_info "Logging into Firebase..."
    echo ""

    firebase login

    if [ $? -ne 0 ]; then
        log_error "Firebase login failed"
        return 1
    fi

    log_success "Firebase login successful"
    return 0
}

gcloud_login() {
    log_step "Google Cloud Login"

    if ! command_exists "gcloud"; then
        log_error "Google Cloud CLI is not installed"
        log_instruction "Install it from: https://cloud.google.com/sdk/docs/install"
        return 1
    fi

    log_info "Logging into Google Cloud..."
    echo ""

    gcloud auth login

    if [ $? -ne 0 ]; then
        log_error "Google Cloud login failed"
        return 1
    fi

    log_success "Google Cloud login successful"
    return 0
}

flutterfire_configure() {
    local app_name="$1"
    local firebase_project_id="$2"

    log_step "Configuring FlutterFire"

    if ! command_exists "flutterfire"; then
        log_error "FlutterFire CLI is not installed"
        log_instruction "Install it with: dart pub global activate flutterfire_cli"
        return 1
    fi

    cd "$app_name" || return 1

    log_info "Running flutterfire configure..."
    log_info "This will create firebase_options.dart and register your app with Firebase"
    echo ""

    flutterfire configure \
        --project="$firebase_project_id" \
        --platforms=android,ios,macos,web,linux,windows

    if [ $? -ne 0 ]; then
        log_error "FlutterFire configuration failed"
        cd ..
        return 1
    fi

    cd .. || return 1

    log_success "FlutterFire configuration complete"
    return 0
}

enable_google_apis() {
    local firebase_project_id="$1"

    log_step "Enabling Google Cloud APIs"

    if ! command_exists "gcloud"; then
        log_warning "Google Cloud CLI not installed, skipping API enablement"
        return 0
    fi

    log_info "Setting Google Cloud project..."
    gcloud config set project "$firebase_project_id"

    log_info "Enabling Artifact Registry API..."
    gcloud services enable artifactregistry.googleapis.com

    log_info "Enabling Cloud Run API..."
    gcloud services enable run.googleapis.com

    log_success "Google Cloud APIs enabled"
    return 0
}

setup_firebase_hosting_sites() {
    local firebase_project_id="$1"

    log_step "Firebase Hosting Sites Setup"

    log_instruction "To enable beta hosting, you need to:"
    log_instruction "1. Go to: https://console.firebase.google.com/project/$firebase_project_id/hosting/sites"
    log_instruction "2. Scroll down and click 'Add another site'"
    log_instruction "3. Enter site ID: ${firebase_project_id}-beta"
    log_instruction "4. Click 'Add site'"
    echo ""

    press_enter "Press Enter when you have completed this step"

    log_success "Firebase hosting sites setup complete"
    return 0
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <app_name> <firebase_project_id>"
        echo "Example: $0 my_app my-firebase-project"
        exit 1
    fi

    firebase_login
    gcloud_login
    enable_google_apis "$2"
    flutterfire_configure "$1" "$2"
fi
