# Setup Script Flags - Complete Reference

This document provides comprehensive documentation and examples for using the `setup.sh` script with command-line flags for automated project creation.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [All Available Flags](#all-available-flags)
- [Usage Examples](#usage-examples)
- [Common Workflows](#common-workflows)
- [Advanced Examples](#advanced-examples)
- [Troubleshooting](#troubleshooting)

---

## Overview

The `setup.sh` script supports two modes:

1. **Interactive Mode** (default): Prompts for all configuration options
2. **Non-Interactive Mode**: Uses command-line flags, no prompts (use `--non-interactive` flag)

You can also use a **hybrid approach**: provide some flags and let the script prompt for the rest.

### When to Use Flags

- **CI/CD pipelines**: Automate project creation in build scripts
- **Batch creation**: Create multiple projects with similar configurations
- **Documentation**: Reproducible project setup instructions
- **Quick iteration**: Rapidly rebuild projects during development

---

## Quick Start

### Minimal Non-Interactive Setup

```bash
./setup.sh \
  --non-interactive \
  --app-name my_app \
  --org com.mycompany \
  --template arcane_template
```

This creates a basic Arcane app with no Firebase, no models package, and no server.

### Full Stack Setup (One Command)

```bash
./setup.sh \
  --non-interactive \
  --app-name my_app \
  --org com.mycompany \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id my-firebase-project \
  --with-cloud-run \
  --skip-deploy
```

---

## All Available Flags

### Configuration Flags

| Flag | Alias | Required | Default | Description |
|------|-------|----------|---------|-------------|
| `--app-name NAME` | `--name` | Yes* | - | App name (lowercase_with_underscores) |
| `--org DOMAIN` | `--organization` | Yes* | `art.arcane` | Organization domain (reverse DNS) |
| `--template TEMPLATE` | - | Yes* | `arcane_template` | Template choice (see below) |
| `--class-name NAME` | `--base-class` | No | Auto-derived | Base class name (PascalCase) |
| `--work-dir PATH` | `--output-dir` | No | Current dir | Directory for project creation |

\* Required only when using `--non-interactive`

#### Template Options

| Value | Description | Platforms |
|-------|-------------|-----------|
| `1` or `arcane_template` | Basic Arcane (no navigation) | All (Web, iOS, Android, Linux, macOS, Windows) |
| `2` or `arcane_beamer` | Arcane with Beamer navigation | All (Web, iOS, Android, Linux, macOS, Windows) |
| `3` or `arcane_dock` | System tray/menu bar app | Desktop only (Linux, macOS, Windows) |

### Project Structure Flags

| Flag | Alias | Description |
|------|-------|-------------|
| `--with-models` | `--models` | Create shared models package |
| `--with-server` | `--server` | Create backend server app |

### Firebase Flags

| Flag | Alias | Required | Description |
|------|-------|----------|-------------|
| `--with-firebase` | `--firebase` | - | Enable Firebase integration |
| `--firebase-project-id ID` | `--firebase-id` | Yes (if `--with-firebase`) | Firebase project ID |
| `--with-cloud-run` | `--cloud-run` | - | Setup Google Cloud Run deployment |
| `--service-account-key PATH` | `--key-file` | - | Path to GCP service account JSON key |

**Note**: `--with-cloud-run` requires both `--with-server` and `--with-firebase`

### Behavior Flags

| Flag | Alias | Description |
|------|-------|-------------|
| `--non-interactive` | `-n` | Non-interactive mode (fail if required flags missing) |
| `--skip-confirm` | - | Skip final confirmation prompts |
| `--skip-cli-check` | - | Skip CLI tool verification (not recommended) |
| `--skip-deploy` | - | Skip optional Firebase deployment at end |
| `--rebuild` | `-r` | Hint to check for existing configuration |
| `--help` | `-h` | Show help message and exit |

---

## Usage Examples

### Example 1: Basic Interactive Setup

```bash
./setup.sh
```

Prompts for all configuration options. Great for first-time users.

### Example 2: Interactive with Pre-filled Values

```bash
./setup.sh --app-name my_app --org com.mycompany
```

Sets app name and organization, prompts for the rest.

### Example 3: Minimal Non-Interactive App

```bash
./setup.sh \
  --non-interactive \
  --app-name simple_app \
  --org art.arcane \
  --template arcane_template
```

Creates a basic Arcane app in the current directory with no Firebase or server.

**Result:**
- `simple_app/` - Client app (all platforms)

### Example 4: App with Models Package

```bash
./setup.sh \
  --non-interactive \
  --app-name data_app \
  --org com.example \
  --template arcane_template \
  --with-models
```

**Result:**
- `data_app/` - Client app
- `data_app_models/` - Shared models package

### Example 5: Full 3-Project Architecture

```bash
./setup.sh \
  --non-interactive \
  --app-name fullstack_app \
  --org com.example \
  --template arcane_beamer \
  --with-models \
  --with-server
```

**Result:**
- `fullstack_app/` - Client app with Beamer navigation
- `fullstack_app_models/` - Shared models package
- `fullstack_app_server/` - Backend server

### Example 6: Firebase-Enabled App (Interactive Firebase Steps)

```bash
./setup.sh \
  --app-name firebase_app \
  --org com.example \
  --template arcane_beamer \
  --with-firebase \
  --firebase-project-id my-firebase-project
```

Uses flags for basic config, but will prompt for:
- Firebase CLI login
- Service account key setup
- Cloud Run configuration

### Example 7: Complete Non-Interactive with Firebase

```bash
./setup.sh \
  --non-interactive \
  --work-dir ~/projects \
  --app-name production_app \
  --org com.example \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id prod-firebase-123 \
  --with-cloud-run \
  --service-account-key ~/keys/service-account.json \
  --skip-deploy
```

Fully automated setup with all components.

### Example 8: Desktop Tray App

```bash
./setup.sh \
  --non-interactive \
  --app-name my_tray_app \
  --org art.arcane \
  --template arcane_dock \
  --with-server
```

**Result:**
- Desktop-only system tray app
- Backend server (optional)

### Example 9: Custom Class Name

```bash
./setup.sh \
  --non-interactive \
  --app-name my_cool_app \
  --class-name CoolApp \
  --org com.example \
  --template arcane_template
```

Override the auto-generated class name.

### Example 10: Rebuild Existing Project

```bash
# First, cd to the directory containing config/setup_config.env
cd ~/projects

# Then rebuild
./setup.sh --rebuild
```

Uses saved configuration from previous run.

---

## Common Workflows

### Workflow 1: Local Development - Quick Iteration

```bash
# Initial setup
./setup.sh \
  --app-name myapp \
  --org com.dev \
  --template arcane_beamer \
  --with-models

# Make changes to templates...

# Rebuild quickly
./setup.sh --rebuild
```

### Workflow 2: CI/CD Pipeline

```bash
#!/bin/bash
# create-project.sh - CI/CD script

./setup.sh \
  --non-interactive \
  --work-dir "$CI_PROJECT_DIR" \
  --app-name "$PROJECT_NAME" \
  --org "$ORG_DOMAIN" \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id "$FIREBASE_PROJECT_ID" \
  --with-cloud-run \
  --skip-deploy \
  --skip-cli-check
```

### Workflow 3: Create Multiple Projects

```bash
#!/bin/bash
# batch-create.sh

PROJECTS=("app1" "app2" "app3")

for project in "${PROJECTS[@]}"; do
  ./setup.sh \
    --non-interactive \
    --work-dir ~/projects \
    --app-name "$project" \
    --org com.mycompany \
    --template arcane_template
done
```

### Workflow 4: Production Deployment Setup

```bash
# Step 1: Create Firebase project manually at console.firebase.google.com
# Step 2: Download service account key
# Step 3: Run setup

./setup.sh \
  --non-interactive \
  --work-dir ~/production \
  --app-name my_production_app \
  --org com.mycompany \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id my-prod-firebase \
  --with-cloud-run \
  --service-account-key ~/keys/prod-service-account.json

# Note: Without --skip-deploy, Firebase resources will be deployed automatically
```

---

## Advanced Examples

### Example A: Custom Working Directory

```bash
./setup.sh \
  --non-interactive \
  --work-dir ~/Documents/Projects/Flutter \
  --app-name enterprise_app \
  --org com.enterprise \
  --template arcane_beamer
```

Creates project in a specific directory.

### Example B: Skip Confirmations (Faster Iteration)

```bash
./setup.sh \
  --app-name testapp \
  --org com.test \
  --template arcane_template \
  --skip-confirm \
  --skip-cli-check
```

Useful for rapid testing, but not recommended for production.

### Example C: Firebase Without Cloud Run

```bash
./setup.sh \
  --non-interactive \
  --app-name firebase_only_app \
  --org com.example \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id my-firebase
```

Firebase enabled, but server won't be configured for Cloud Run deployment.

### Example D: Environment Variable Based Setup

```bash
#!/bin/bash
# Use environment variables for configuration

export APP_NAME="env_app"
export ORG_DOMAIN="com.envexample"
export FIREBASE_ID="env-firebase-123"

./setup.sh \
  --non-interactive \
  --app-name "$APP_NAME" \
  --org "$ORG_DOMAIN" \
  --template arcane_beamer \
  --with-firebase \
  --firebase-project-id "$FIREBASE_ID"
```

### Example E: Template-Specific Configurations

```bash
# For Beamer navigation app
./setup.sh \
  --non-interactive \
  --app-name nav_app \
  --org com.example \
  --template 2 \
  --with-models

# For desktop tray app (no mobile platforms)
./setup.sh \
  --non-interactive \
  --app-name tray_app \
  --org com.example \
  --template 3
```

---

## Troubleshooting

### Missing Required Flags Error

**Error:**
```
Non-interactive mode requires the following flags:
  --app-name
  --org
```

**Solution:**
Add all required flags when using `--non-interactive`:
```bash
./setup.sh --non-interactive --app-name myapp --org com.example --template arcane_template
```

### Invalid App Name Error

**Error:**
```
Invalid app name: MyApp
Value must be lowercase
```

**Solution:**
Use lowercase with underscores:
```bash
./setup.sh --app-name my_app  # Correct
```

### Firebase Project ID Missing

**Error:**
```
--firebase-project-id (required when --with-firebase is set)
```

**Solution:**
Provide Firebase project ID when enabling Firebase:
```bash
./setup.sh --with-firebase --firebase-project-id my-firebase-project
```

### Directory Does Not Exist

**Error:**
```
Directory does not exist: /invalid/path
```

**Solution:**
Either create the directory first or remove `--non-interactive` to allow interactive creation:
```bash
mkdir -p ~/projects
./setup.sh --work-dir ~/projects --non-interactive ...
```

### Service Account Key Not Found

**Error:**
```
Service account key file not found: /path/to/key.json
```

**Solution:**
Ensure the file exists and the path is correct:
```bash
ls -la /path/to/key.json  # Verify file exists
./setup.sh --service-account-key /path/to/key.json ...
```

### Cloud Run Without Server

**Error:**
Cloud Run setup is requested but server is not enabled.

**Solution:**
Include `--with-server` when using `--with-cloud-run`:
```bash
./setup.sh --with-server --with-cloud-run ...
```

---

## Flag Validation Rules

### App Name
- **Required**: Yes (in non-interactive mode)
- **Format**: lowercase with underscores only
- **Valid**: `my_app`, `cool_app_123`, `app_v2`
- **Invalid**: `MyApp` (uppercase), `my-app` (hyphens), `my app` (spaces)

### Organization Domain
- **Required**: Yes (in non-interactive mode)
- **Format**: Reverse domain notation (any format accepted)
- **Valid**: `com.mycompany`, `art.arcane`, `io.github.username`
- **Default**: `art.arcane`

### Firebase Project ID
- **Required**: Only if `--with-firebase` is used
- **Format**: lowercase letters, numbers, and hyphens only
- **Valid**: `my-project`, `firebase123`, `prod-app-2024`
- **Invalid**: `My_Project` (uppercase/underscore), `project.name` (dot)

### Class Name
- **Required**: No (auto-derived from app name)
- **Format**: PascalCase (any format accepted)
- **Example**: `my_app` → `MyApp` (auto-derived)

---

## Configuration File

After running setup, configuration is saved to:
```
<working_directory>/config/setup_config.env
```

**Example content:**
```bash
APP_NAME=my_app
ORG_DOMAIN=com.example
BASE_CLASS_NAME=MyApp
TEMPLATE_DIR=/path/to/arcane_templates/arcane_beamer
TEMPLATE_NAME=arcane_beamer
PLATFORMS=android,ios,web,linux,windows,macos
CREATE_MODELS=yes
CREATE_SERVER=yes
USE_FIREBASE=yes
FIREBASE_PROJECT_ID=my-firebase-project
SETUP_CLOUD_RUN=yes
```

This allows easy rebuilds with `./setup.sh --rebuild`.

---

## Tips & Best Practices

### 1. Start Simple
Begin with minimal flags and add complexity as needed:
```bash
# Start here
./setup.sh --app-name myapp --org com.example --template arcane_template

# Then add features
./setup.sh --app-name myapp --org com.example --template arcane_beamer --with-models
```

### 2. Use Aliases for Common Setups
Create shell aliases for frequently used configurations:
```bash
# In ~/.bashrc or ~/.zshrc
alias arcane-basic='./setup.sh --non-interactive --template arcane_template'
alias arcane-full='./setup.sh --template arcane_beamer --with-models --with-server'

# Usage
arcane-basic --app-name testapp --org com.test
```

### 3. Document Your Commands
Save your setup commands in a README for team members:
```markdown
# Project Setup

To recreate this project:

\`\`\`bash
./setup.sh \
  --app-name my_production_app \
  --org com.mycompany \
  --template arcane_beamer \
  --with-models \
  --with-server \
  --with-firebase \
  --firebase-project-id prod-firebase-123
\`\`\`
```

### 4. Use `--skip-deploy` for Initial Setup
When setting up, use `--skip-deploy` to prevent automatic Firebase deployment:
```bash
./setup.sh ... --skip-deploy
# Manually deploy later when ready
```

### 5. Leverage `--rebuild` for Development
During template development, use `--rebuild` to quickly iterate:
```bash
# Initial setup
./setup.sh --app-name dev_app --org com.dev --template arcane_template

# Modify templates...

# Rebuild
./setup.sh --rebuild  # Uses saved config
```

---

## Quick Reference Card

```
# BASIC SETUP
./setup.sh --app-name NAME --org DOMAIN --template TEMPLATE

# WITH MODELS + SERVER
./setup.sh ... --with-models --with-server

# WITH FIREBASE
./setup.sh ... --with-firebase --firebase-project-id ID

# WITH CLOUD RUN (requires Firebase + Server)
./setup.sh ... --with-firebase --with-server --with-cloud-run --firebase-project-id ID

# NON-INTERACTIVE (no prompts)
./setup.sh --non-interactive ...

# SKIP CONFIRMATIONS
./setup.sh ... --skip-confirm --skip-deploy

# REBUILD
./setup.sh --rebuild
```

---

## Getting Help

- **Show all flags**: `./setup.sh --help`
- **Report issues**: https://github.com/arcanearts/arcane_templates/issues
- **Documentation**: See `CLAUDE.md` for full project documentation

---

**Last Updated**: 2024

**Script Version**: Compatible with setup.sh v2.0+ (flag support)
