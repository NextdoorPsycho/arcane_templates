#!/bin/bash

# Check CLI Tools
# Verifies that required and optional CLI tools are installed

# Source utilities
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/utils.sh"

check_cli_tools() {
    log_step "Checking Required CLI Tools"

    local all_required_installed=true
    local required_tools=("flutter" "dart")
    local optional_tools=("firebase" "flutterfire" "gcloud" "docker" "npm")
    local macos_tools=("brew" "pod")

    # Check required tools
    log_info "Checking required tools..."
    for tool in "${required_tools[@]}"; do
        if command_exists "$tool"; then
            local version=$($tool --version 2>&1 | head -n 1)
            log_success "$tool is installed: $version"
        else
            log_error "$tool is NOT installed (REQUIRED)"
            all_required_installed=false
        fi
    done

    echo ""

    # Check optional tools
    log_info "Checking optional tools (for Firebase and server deployment)..."
    for tool in "${optional_tools[@]}"; do
        if command_exists "$tool"; then
            local version=""
            case "$tool" in
                firebase|npm)
                    version=$($tool --version 2>&1)
                    ;;
                flutterfire)
                    version="installed"
                    ;;
                gcloud)
                    version=$($tool version 2>&1 | head -n 1)
                    ;;
                docker)
                    version=$($tool --version 2>&1 | head -n 1)
                    ;;
            esac
            log_success "$tool is installed: $version"
        else
            log_warning "$tool is NOT installed (optional, needed for Firebase/server)"
        fi
    done

    echo ""

    # Check macOS-specific tools
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Checking macOS-specific tools (for iOS/macOS development)..."
        for tool in "${macos_tools[@]}"; do
            if command_exists "$tool"; then
                local version=""
                case "$tool" in
                    brew)
                        version=$(brew --version 2>&1 | head -n 1)
                        ;;
                    pod)
                        version=$(pod --version 2>&1)
                        ;;
                esac
                log_success "$tool is installed: $version"
            else
                log_warning "$tool is NOT installed (optional, for iOS/macOS)"
            fi
        done
        echo ""
    fi

    if [ "$all_required_installed" = false ]; then
        log_error "Some required tools are missing. Please install them before continuing."
        echo ""
        log_info "Installation instructions:"
        log_instruction "Flutter: https://flutter.dev/docs/get-started/install"
        log_instruction "Dart: Included with Flutter"
        echo ""
        return 1
    fi

    log_success "All required CLI tools are installed!"
    echo ""

    # Show optional tool installation instructions if needed
    local show_optional_instructions=false
    for tool in "${optional_tools[@]}"; do
        if ! command_exists "$tool"; then
            show_optional_instructions=true
            break
        fi
    done

    if [ "$show_optional_instructions" = true ]; then
        log_info "Optional tools installation instructions:"
        if ! command_exists "firebase"; then
            log_instruction "Firebase CLI: npm install -g firebase-tools"
        fi
        if ! command_exists "flutterfire"; then
            log_instruction "FlutterFire CLI: dart pub global activate flutterfire_cli"
        fi
        if ! command_exists "gcloud"; then
            log_instruction "Google Cloud CLI: https://cloud.google.com/sdk/docs/install"
        fi
        if ! command_exists "docker"; then
            log_instruction "Docker: https://docs.docker.com/get-docker/"
        fi
        if ! command_exists "npm"; then
            log_instruction "Node.js/npm: https://nodejs.org/"
        fi
        echo ""
    fi

    return 0
}

check_flutter_doctor() {
    log_step "Running Flutter Doctor"

    log_info "Checking Flutter environment..."
    echo ""

    flutter doctor

    echo ""
    log_info "If you see issues above, you may want to resolve them before continuing."
    echo ""

    if ! confirm "Continue with setup?"; then
        log_warning "Setup cancelled by user"
        exit 0
    fi
}

# Run checks if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    check_cli_tools
    if [ $? -eq 0 ]; then
        check_flutter_doctor
    fi
fi
