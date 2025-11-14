#!/bin/bash

# Deploy Firebase
# Deploys Firestore rules, Storage rules, and web app to Firebase Hosting

# Source utilities
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/utils.sh"

deploy_firestore() {
    log_step "Deploying Firestore Rules and Indexes"

    if ! command_exists "firebase"; then
        log_error "Firebase CLI is not installed"
        return 1
    fi

    log_info "Deploying Firestore rules and indexes..."
    echo ""

    firebase deploy --only firestore

    if [ $? -ne 0 ]; then
        log_error "Failed to deploy Firestore"
        return 1
    fi

    log_success "Firestore deployed successfully"
    return 0
}

deploy_storage() {
    log_step "Deploying Storage Rules"

    if ! command_exists "firebase"; then
        log_error "Firebase CLI is not installed"
        return 1
    fi

    log_info "Deploying Storage rules..."
    echo ""

    firebase deploy --only storage

    if [ $? -ne 0 ]; then
        log_error "Failed to deploy Storage"
        return 1
    fi

    log_success "Storage deployed successfully"
    return 0
}

build_web_app() {
    local app_name="$1"

    log_step "Building Web App for Production"

    cd "$app_name" || return 1

    log_info "Running flutter build web --release..."
    echo ""

    flutter build web --release

    if [ $? -ne 0 ]; then
        log_error "Failed to build web app"
        cd ..
        return 1
    fi

    cd .. || return 1

    log_success "Web app built successfully"
    return 0
}

deploy_hosting_release() {
    log_step "Deploying to Firebase Hosting (Release)"

    if ! command_exists "firebase"; then
        log_error "Firebase CLI is not installed"
        return 1
    fi

    log_info "Deploying to Firebase Hosting (release target)..."
    echo ""

    firebase deploy --only hosting:release

    if [ $? -ne 0 ]; then
        log_error "Failed to deploy to hosting (release)"
        return 1
    fi

    log_success "Release hosting deployed successfully"
    return 0
}

deploy_hosting_beta() {
    log_step "Deploying to Firebase Hosting (Beta)"

    if ! command_exists "firebase"; then
        log_error "Firebase CLI is not installed"
        return 1
    fi

    log_info "Deploying to Firebase Hosting (beta target)..."
    echo ""

    firebase deploy --only hosting:beta

    if [ $? -ne 0 ]; then
        log_warning "Failed to deploy to hosting (beta)"
        log_instruction "Make sure you've created the beta site in Firebase Console"
        return 1
    fi

    log_success "Beta hosting deployed successfully"
    return 0
}

deploy_all_firebase() {
    local app_name="$1"

    # Deploy Firestore
    deploy_firestore || log_warning "Firestore deployment failed, continuing..."

    # Deploy Storage
    deploy_storage || log_warning "Storage deployment failed, continuing..."

    # Build and deploy web app
    if confirm "Do you want to build and deploy the web app to Firebase Hosting?"; then
        build_web_app "$app_name"

        deploy_hosting_release

        log_info "To deploy beta, ensure you've created the beta site in Firebase Console"
        if confirm "Do you want to deploy to beta hosting site?"; then
            deploy_hosting_beta
        fi
    fi

    log_success "Firebase deployment complete"
    return 0
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <app_name>"
        echo "Example: $0 my_app"
        exit 1
    fi

    deploy_all_firebase "$1"
fi
