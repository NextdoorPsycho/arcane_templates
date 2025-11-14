#!/bin/bash

# Arcane Template Setup Wizard
# Main orchestration script for creating a complete 3-project Flutter application

set -e  # Exit on error

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all library scripts
source "$SCRIPT_DIR/scripts/lib/utils.sh"
source "$SCRIPT_DIR/scripts/lib/check_tools.sh"
source "$SCRIPT_DIR/scripts/lib/create_projects.sh"
source "$SCRIPT_DIR/scripts/lib/add_dependencies.sh"
source "$SCRIPT_DIR/scripts/lib/setup_firebase.sh"
source "$SCRIPT_DIR/scripts/lib/generate_configs.sh"
source "$SCRIPT_DIR/scripts/lib/generate_assets.sh"
source "$SCRIPT_DIR/scripts/lib/setup_server.sh"
source "$SCRIPT_DIR/scripts/lib/deploy_firebase.sh"

# Configuration file
CONFIG_FILE="config/setup_config.env"

# Main setup function

main() {
    print_banner

    log_info "Welcome to the Arcane Template Setup Wizard!"
    log_info "This wizard will guide you through creating a complete Flutter app"
    log_info "with the Arcane UI framework, including client, models, and server."
    echo ""

    log_info "Current directory: $(pwd)"
    log_instruction "Projects will be created as subdirectories in this location."
    echo ""

    if ! confirm "Do you want to continue?"; then
        log_warning "Setup cancelled by user"
        exit 0
    fi

    # Step 1: Check CLI tools
    print_header "Step 1: Checking CLI Tools"
    check_cli_tools || exit 1

    # Step 2: Gather project information
    print_header "Step 2: Project Configuration"
    gather_project_info

    # Step 3: Optional Firebase setup
    print_header "Step 3: Firebase Configuration (Optional)"
    configure_firebase_options

    # Step 4: Show summary and confirm
    print_header "Step 4: Configuration Summary"
    show_configuration_summary

    if ! confirm "Proceed with these settings?"; then
        log_warning "Setup cancelled by user"
        exit 0
    fi

    # Save configuration
    save_configuration

    # Step 5: Create projects
    print_header "Step 5: Creating Projects"
    create_all_projects "$APP_NAME" "$ORG_DOMAIN" || exit 1

    # Step 6: Add dependencies
    print_header "Step 6: Adding Dependencies"
    add_all_dependencies "$APP_NAME" "$USE_FIREBASE" || exit 1

    # Step 7: Setup Firebase (if enabled)
    if [ "$USE_FIREBASE" = "yes" ]; then
        print_header "Step 7: Setting Up Firebase"
        setup_firebase_integration
    fi

    # Step 8: Generate configuration files
    print_header "Step 8: Generating Configuration Files"
    if [ "$USE_FIREBASE" = "yes" ]; then
        generate_all_configs "$APP_NAME" "$FIREBASE_PROJECT_ID"
    fi

    # Step 9: Copy template assets
    print_header "Step 9: Setting Up Assets"
    copy_template_assets "$APP_NAME" "$TEMPLATE_DIR"
    update_pubspec_for_assets "$APP_NAME"

    # Step 10: Configure platform versions and generate assets
    print_header "Step 10: Generating App Icons and Splash Screens"
    generate_all_assets "$APP_NAME"

    # Step 11: Setup server
    print_header "Step 11: Setting Up Server"
    setup_server "$APP_NAME"

    # Step 12: Clean up test folders
    delete_test_folders "$APP_NAME"

    # Step 13: Optional Firebase deployment
    if [ "$USE_FIREBASE" = "yes" ]; then
        print_header "Step 13: Firebase Deployment (Optional)"
        if confirm "Do you want to deploy Firebase resources now?"; then
            deploy_all_firebase "$APP_NAME"
        else
            log_info "You can deploy Firebase resources later using:"
            log_instruction "  firebase deploy --only firestore"
            log_instruction "  firebase deploy --only storage"
            log_instruction "  firebase deploy --only hosting"
        fi
    fi

    # Final summary
    print_header "🎉 Setup Complete! 🎉"
    show_final_summary

    log_success "Your Arcane application is ready!"
}

gather_project_info() {
    log_step "Gathering Project Information"

    # Organization domain
    prompt_with_validation \
        "Organization domain (e.g., com.mycompany, art.arcane)" \
        validate_not_empty \
        ORG_DOMAIN \
        "art.arcane"

    # App name
    prompt_with_validation \
        "App name (lowercase_with_underscores, e.g., my_app)" \
        validate_app_name \
        APP_NAME \
        "my_app"

    # Base class name
    local default_class_name=$(snake_to_pascal "$APP_NAME")
    prompt_with_validation \
        "Base class name (PascalCase, e.g., MyApp)" \
        validate_not_empty \
        BASE_CLASS_NAME \
        "$default_class_name"

    # Template selection
    echo ""
    log_info "Select template:"
    log_instruction "1) arcane_template (no navigation framework)"
    log_instruction "2) arcane_beamer (with Beamer navigation)"
    echo ""

    local template_choice
    read -p "$(echo -e ${CYAN}❯${NC}) Enter choice [1-2] (default: 1): " template_choice
    template_choice="${template_choice:-1}"

    case "$template_choice" in
        1)
            TEMPLATE_DIR="$SCRIPT_DIR/arcane_template"
            TEMPLATE_NAME="arcane_template"
            ;;
        2)
            TEMPLATE_DIR="$SCRIPT_DIR/arcane_beamer"
            TEMPLATE_NAME="arcane_beamer"
            ;;
        *)
            log_warning "Invalid choice, using arcane_template"
            TEMPLATE_DIR="$SCRIPT_DIR/arcane_template"
            TEMPLATE_NAME="arcane_template"
            ;;
    esac

    log_success "Template selected: $TEMPLATE_NAME"
}

configure_firebase_options() {
    log_step "Firebase Configuration"

    log_info "Firebase integration is optional but recommended for:"
    log_instruction "• Authentication"
    log_instruction "• Cloud Firestore database"
    log_instruction "• Cloud Storage"
    log_instruction "• Analytics and Crashlytics"
    log_instruction "• Web hosting"
    echo ""

    if confirm "Do you want to use Firebase?"; then
        USE_FIREBASE="yes"

        echo ""
        log_instruction "Before continuing, you should:"
        log_instruction "1. Create a Firebase project at: https://console.firebase.google.com/"
        log_instruction "2. Create a Firestore database (use nam5 if US-based)"
        log_instruction "3. Set up authentication providers (Email/Password, Google, Apple)"
        log_instruction "4. Enable billing (upgrade to Blaze plan for some features)"
        echo ""

        press_enter "Press Enter when you've completed Firebase project creation"

        echo ""
        prompt_with_validation \
            "Firebase Project ID (from Firebase Console URL)" \
            validate_firebase_project_id \
            FIREBASE_PROJECT_ID

        echo ""
        log_instruction "You'll need to create a Google Cloud service account:"
        log_instruction "1. Go to: https://console.cloud.google.com/iam-admin/serviceaccounts/create?project=$FIREBASE_PROJECT_ID"
        log_instruction "2. Service account name: ${FIREBASE_PROJECT_ID}-server"
        log_instruction "3. Add role: Basic > Owner"
        log_instruction "4. Create and download JSON key"
        log_instruction "5. Save the JSON file to: config/keys/"
        echo ""

        if confirm "Have you created and downloaded the service account key?"; then
            # Check if key exists
            ensure_directory "config/keys"
            local key_count=$(find config/keys -name "*.json" -type f 2>/dev/null | wc -l)

            if [ "$key_count" -eq 0 ]; then
                log_warning "No JSON key files found in config/keys/"
                log_instruction "Please add your service account key to config/keys/ before proceeding"
                press_enter
            else
                log_success "Service account key found"
            fi
        fi

        echo ""
        if confirm "Do you want to setup Google Cloud Run for server deployment?"; then
            SETUP_CLOUD_RUN="yes"

            log_instruction "You'll need to create an Artifact Registry:"
            log_instruction "1. Go to: https://console.cloud.google.com/artifacts/create-repo?project=$FIREBASE_PROJECT_ID"
            log_instruction "2. Name: cloud-run-source-deploy"
            log_instruction "3. Format: Docker, Region: us-central1"
            log_instruction "4. Add cleanup policies (keep 2 versions, delete old)"
            echo ""

            press_enter "Press Enter when you've created the Artifact Registry"
        else
            SETUP_CLOUD_RUN="no"
        fi

    else
        USE_FIREBASE="no"
        FIREBASE_PROJECT_ID=""
        SETUP_CLOUD_RUN="no"
    fi
}

show_configuration_summary() {
    log_step "Configuration Summary"

    echo ""
    log_info "Project Configuration:"
    log_instruction "  Organization: $ORG_DOMAIN"
    log_instruction "  App Name: $APP_NAME"
    log_instruction "  Base Class: $BASE_CLASS_NAME"
    log_instruction "  Template: $TEMPLATE_NAME"
    echo ""

    log_info "Projects to be created:"
    log_instruction "  $(pwd)/$APP_NAME"
    log_instruction "  $(pwd)/${APP_NAME}_models"
    log_instruction "  $(pwd)/${APP_NAME}_server"
    echo ""

    if [ "$USE_FIREBASE" = "yes" ]; then
        log_info "Firebase Configuration:"
        log_instruction "  Project ID: $FIREBASE_PROJECT_ID"
        log_instruction "  Cloud Run: $SETUP_CLOUD_RUN"
    else
        log_info "Firebase: Not configured"
    fi
    echo ""
}

save_configuration() {
    log_info "Saving configuration..."

    ensure_directory "config"

    cat > "$CONFIG_FILE" << EOF
# Arcane Template Setup Configuration
# Generated on $(date)

APP_NAME=$APP_NAME
ORG_DOMAIN=$ORG_DOMAIN
BASE_CLASS_NAME=$BASE_CLASS_NAME
TEMPLATE_DIR=$TEMPLATE_DIR
TEMPLATE_NAME=$TEMPLATE_NAME
USE_FIREBASE=$USE_FIREBASE
FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
SETUP_CLOUD_RUN=$SETUP_CLOUD_RUN
EOF

    log_success "Configuration saved to $CONFIG_FILE"
}

setup_firebase_integration() {
    log_step "Setting Up Firebase Integration"

    # Login to Firebase and gcloud
    firebase_login || log_warning "Firebase login failed, you can login manually later"
    gcloud_login || log_warning "gcloud login failed, you can login manually later"

    # Enable Google APIs
    if [ "$SETUP_CLOUD_RUN" = "yes" ]; then
        enable_google_apis "$FIREBASE_PROJECT_ID" || log_warning "Failed to enable some Google APIs"
    fi

    # Configure FlutterFire
    flutterfire_configure "$APP_NAME" "$FIREBASE_PROJECT_ID" || log_warning "FlutterFire configuration failed"
}

show_final_summary() {
    echo ""
    log_success "Project Structure:"
    log_instruction "  $APP_NAME/              - Client application"
    log_instruction "  ${APP_NAME}_models/     - Shared models package"
    log_instruction "  ${APP_NAME}_server/     - Server application"
    log_instruction "  config/                 - Configuration files"
    echo ""

    log_info "Next Steps:"
    echo ""

    log_instruction "1. Run your app:"
    log_instruction "   cd $APP_NAME"
    log_instruction "   flutter run"
    echo ""

    log_instruction "2. Customize your app icons and splash screen:"
    log_instruction "   • Replace $APP_NAME/assets/icon/icon.png (1024x1024)"
    log_instruction "   • Replace $APP_NAME/assets/icon/splash.png"
    log_instruction "   • Run: cd $APP_NAME && dart run flutter_launcher_icons"
    log_instruction "   • Run: cd $APP_NAME && dart run flutter_native_splash:create"
    echo ""

    if [ "$USE_FIREBASE" = "yes" ]; then
        log_instruction "3. Deploy to Firebase Hosting:"
        log_instruction "   cd $APP_NAME"
        log_instruction "   flutter build web --release"
        log_instruction "   cd .."
        log_instruction "   firebase deploy --only hosting"
        echo ""

        if [ "$SETUP_CLOUD_RUN" = "yes" ]; then
            log_instruction "4. Deploy server to Google Cloud Run:"
            log_instruction "   cd ${APP_NAME}_server"
            log_instruction "   gcloud builds submit --tag us-central1-docker.pkg.dev/$FIREBASE_PROJECT_ID/cloud-run-source-deploy/${APP_NAME}_server"
            log_instruction "   gcloud run deploy ${APP_NAME}_server --image us-central1-docker.pkg.dev/$FIREBASE_PROJECT_ID/cloud-run-source-deploy/${APP_NAME}_server --region us-central1"
            echo ""
        fi
    fi

    log_info "Documentation:"
    log_instruction "• Setup Guide: $TEMPLATE_DIR/SETUP.md"
    log_instruction "• README: $TEMPLATE_DIR/README.md"
    log_instruction "• Helper Scripts: scripts/README.md"
    echo ""

    log_success "Enjoy building with Arcane! 🚀"
}

# Run main function
main "$@"
