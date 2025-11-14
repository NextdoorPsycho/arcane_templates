#!/bin/bash

# Setup Server
# Creates Dockerfiles and configuration for server deployment

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

create_server_dockerfile() {
    local app_name="$1"
    local server_name="${app_name}_server"

    log_step "Creating Server Dockerfile"

    cat > "$server_name/Dockerfile" << 'EOF'
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Setup Flutter
RUN flutter config --no-analytics
RUN flutter precache --linux

# Copy app
WORKDIR /app
COPY . .

# Get dependencies and build
RUN flutter pub get
RUN flutter build linux --release

# Expose port
EXPOSE 8080

# Run server
CMD ["/app/build/linux/x64/release/bundle/SERVER_NAME"]
EOF

    # Replace SERVER_NAME placeholder
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/SERVER_NAME/${server_name}/" "$server_name/Dockerfile"
    else
        sed -i "s/SERVER_NAME/${server_name}/" "$server_name/Dockerfile"
    fi

    log_success "Dockerfile created for server"
}

create_server_dockerfile_dev() {
    local app_name="$1"
    local server_name="${app_name}_server"

    log_info "Creating development Dockerfile..."

    cat > "$server_name/Dockerfile-dev" << 'EOF'
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Setup Flutter
RUN flutter config --no-analytics
RUN flutter precache --linux

# Copy app
WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Expose port
EXPOSE 8080

# Run server in debug mode
CMD ["flutter", "run", "--release", "-d", "linux-server"]
EOF

    log_success "Development Dockerfile created"
}

copy_service_account_key() {
    local app_name="$1"
    local server_name="${app_name}_server"

    log_step "Setting Up Service Account Key"

    # Find service account key in config/keys
    local key_file=$(find config/keys -name "*.json" -type f | head -n 1)

    if [ -z "$key_file" ]; then
        log_warning "No service account key found in config/keys/"
        log_instruction "If you need Firebase access from the server, add your service account key to config/keys/"
        return 0
    fi

    log_info "Copying service account key to server..."

    cp "$key_file" "$server_name/"

    if [ $? -ne 0 ]; then
        log_warning "Failed to copy service account key"
        return 0
    fi

    log_success "Service account key copied to server"

    # Add to .gitignore
    echo "*.json" >> "$server_name/.gitignore"

    log_warning "IMPORTANT: Service account keys should NEVER be committed to git!"
    log_instruction "Added *.json to $server_name/.gitignore"

    return 0
}

setup_server() {
    local app_name="$1"

    create_server_dockerfile "$app_name"
    create_server_dockerfile_dev "$app_name"
    copy_service_account_key "$app_name"

    log_success "Server setup complete"
    return 0
}

# Run if script is executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <app_name>"
        echo "Example: $0 my_app"
        exit 1
    fi

    setup_server "$1"
fi
