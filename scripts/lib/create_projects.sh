#!/bin/bash

# Create Projects
# Creates the 3-project architecture: client app, models package, and server

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

create_client_app() {
    local app_name="$1"
    local org="$2"

    log_step "Creating Client App: $app_name"

    if [ -d "$app_name" ]; then
        log_warning "Directory $app_name already exists"
        if ! confirm "Do you want to overwrite it?"; then
            log_error "Cannot continue without creating the app"
            return 1
        fi
    fi

    log_info "Running flutter create for client app..."
    echo ""

    flutter create \
        --platforms=android,ios,web,linux,windows,macos \
        -a java \
        -t app \
        --suppress-analytics \
        -e \
        --org "$org" \
        --project-name "$app_name" \
        --overwrite \
        "$app_name"

    if [ $? -ne 0 ]; then
        log_error "Failed to create client app"
        return 1
    fi

    log_success "Client app created: $app_name"
    return 0
}

create_models_package() {
    local app_name="$1"
    local models_name="${app_name}_models"

    log_step "Creating Models Package: $models_name"

    if [ -d "$models_name" ]; then
        log_warning "Directory $models_name already exists"
        if ! confirm "Do you want to overwrite it?"; then
            log_error "Cannot continue without creating the models package"
            return 1
        fi
    fi

    log_info "Running flutter create for models package..."
    echo ""

    flutter create \
        -t package \
        --suppress-analytics \
        --project-name "$models_name" \
        --overwrite \
        "$models_name"

    if [ $? -ne 0 ]; then
        log_error "Failed to create models package"
        return 1
    fi

    log_success "Models package created: $models_name"
    return 0
}

create_server_app() {
    local app_name="$1"
    local org="$2"
    local server_name="${app_name}_server"

    log_step "Creating Server App: $server_name"

    if [ -d "$server_name" ]; then
        log_warning "Directory $server_name already exists"
        if ! confirm "Do you want to overwrite it?"; then
            log_error "Cannot continue without creating the server"
            return 1
        fi
    fi

    log_info "Running flutter create for server app..."
    echo ""

    flutter create \
        --platforms=linux \
        -t app \
        --suppress-analytics \
        -e \
        --org "$org" \
        --project-name "$server_name" \
        --overwrite \
        "$server_name"

    if [ $? -ne 0 ]; then
        log_error "Failed to create server app"
        return 1
    fi

    log_success "Server app created: $server_name"
    return 0
}

link_models_to_projects() {
    local app_name="$1"
    local models_name="${app_name}_models"
    local server_name="${app_name}_server"

    log_step "Linking Models Package to Client and Server"

    # Add models dependency to client app
    log_info "Adding models dependency to $app_name..."

    cat >> "$app_name/pubspec.yaml" << EOF

  $models_name:
    path: ../$models_name
EOF

    log_success "Added models dependency to client app"

    # Add models dependency to server app
    log_info "Adding models dependency to $server_name..."

    cat >> "$server_name/pubspec.yaml" << EOF

  $models_name:
    path: ../$models_name
EOF

    log_success "Added models dependency to server app"

    return 0
}

create_all_projects() {
    local app_name="$1"
    local org="$2"

    log_info "Current directory: $(pwd)"
    log_info "Projects will be created as:"
    log_instruction "  /$app_name - Flutter client application"
    log_instruction "  /${app_name}_models - Shared Dart package"
    log_instruction "  /${app_name}_server - Flutter server application"
    echo ""

    if ! confirm "Create these projects?"; then
        log_warning "Project creation cancelled"
        return 1
    fi

    # Create client app
    create_client_app "$app_name" "$org" || return 1

    # Create models package
    create_models_package "$app_name" || return 1

    # Create server app
    create_server_app "$app_name" "$org" || return 1

    # Link models to projects
    link_models_to_projects "$app_name" || return 1

    log_success "All projects created successfully!"

    return 0
}

delete_test_folders() {
    local app_name="$1"
    local models_name="${app_name}_models"
    local server_name="${app_name}_server"

    log_step "Cleaning Up Test Folders"

    local test_folders=(
        "$models_name/test"
        "$app_name/test"
        "$server_name/test"
    )

    for folder in "${test_folders[@]}"; do
        if [ -d "$folder" ]; then
            log_info "Removing $folder..."
            rm -rf "$folder"
            log_success "Removed $folder"
        fi
    done

    return 0
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ $# -ne 2 ]; then
        echo "Usage: $0 <app_name> <org>"
        echo "Example: $0 my_app art.arcane"
        exit 1
    fi

    create_all_projects "$1" "$2"
fi
