#!/bin/bash

# ConfigUtils Setup Script
# This script installs .colin.bashrc and configures ~/.bashrc to source it

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_BASHRC="$SCRIPT_DIR/2025/.colin.bashrc"
TARGET_BASHRC="$HOME/.colin.bashrc"
USER_BASHRC="$HOME/.bashrc"

log_info "ConfigUtils Setup Starting..."
log_info "Script directory: $SCRIPT_DIR"
log_info "Project bashrc: $PROJECT_BASHRC"
log_info "Target location: $TARGET_BASHRC"

# Check if project .colin.bashrc exists
if [[ ! -f "$PROJECT_BASHRC" ]]; then
    log_error "Project .colin.bashrc not found at: $PROJECT_BASHRC"
    exit 1
fi

# Step 1: Copy project .colin.bashrc to home directory
log_info "Copying .colin.bashrc to home directory..."

# Create backup if target exists
if [[ -f "$TARGET_BASHRC" ]]; then
    BACKUP_FILE="${TARGET_BASHRC}.backup.$(date +%Y%m%d_%H%M%S)"
    log_warning "Existing .colin.bashrc found. Creating backup: $BACKUP_FILE"
    cp "$TARGET_BASHRC" "$BACKUP_FILE"
fi

# Copy the file
cp "$PROJECT_BASHRC" "$TARGET_BASHRC"
log_success "Copied .colin.bashrc to $TARGET_BASHRC"

# Step 2: Check and configure ~/.bashrc
log_info "Checking ~/.bashrc configuration..."

# Create ~/.bashrc if it doesn't exist
if [[ ! -f "$USER_BASHRC" ]]; then
    log_warning "~/.bashrc not found. Creating it..."
    touch "$USER_BASHRC"
fi

# Check if ~/.bashrc already sources .colin.bashrc
SOURCE_PATTERNS=(
    "source ~/.colin.bashrc"
    ". ~/.colin.bashrc"
    "source \$HOME/.colin.bashrc"
    ". \$HOME/.colin.bashrc"
    'source "$HOME/.colin.bashrc"'
    '. "$HOME/.colin.bashrc"'
)

ALREADY_CONFIGURED=false

for pattern in "${SOURCE_PATTERNS[@]}"; do
    if grep -Fq "$pattern" "$USER_BASHRC"; then
        log_success "Found existing configuration: $pattern"
        ALREADY_CONFIGURED=true
        break
    fi
done

# If not configured, add the source line
if [[ "$ALREADY_CONFIGURED" == false ]]; then
    log_info "Adding .colin.bashrc source line to ~/.bashrc..."

    # Create backup of ~/.bashrc
    BASHRC_BACKUP="${USER_BASHRC}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$USER_BASHRC" "$BASHRC_BACKUP"
    log_info "Created backup of ~/.bashrc: $BASHRC_BACKUP"

    # Add source line with comment
    {
        echo ""
        echo "# ConfigUtils - Load Colin's custom bashrc"
        echo "if [[ -f ~/.colin.bashrc ]]; then"
        echo "    source ~/.colin.bashrc"
        echo "fi"
    } >> "$USER_BASHRC"

    log_success "Added .colin.bashrc sourcing to ~/.bashrc"
else
    log_info "~/.bashrc already configured to source .colin.bashrc"
fi

# Step 3: Verify setup
log_info "Verifying setup..."

# Check if target file exists and is readable
if [[ -f "$TARGET_BASHRC" && -r "$TARGET_BASHRC" ]]; then
    log_success "✓ .colin.bashrc is installed and readable"
else
    log_error "✗ .colin.bashrc installation failed"
    exit 1
fi

# Check if ~/.bashrc sources the file
if grep -q "\.colin\.bashrc" "$USER_BASHRC"; then
    log_success "✓ ~/.bashrc is configured to source .colin.bashrc"
else
    log_error "✗ ~/.bashrc configuration failed"
    exit 1
fi

# Final instructions
echo ""
log_success "Setup completed successfully!"
echo ""
echo "To activate the changes, either:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Open a new terminal session"
echo ""
echo "Your custom functions and aliases from .colin.bashrc are now available."

# Test if we can detect some functions (optional check)
if command -v bash >/dev/null 2>&1; then
    log_info "Testing configuration..."
    if bash -c "source ~/.bashrc && declare -f dictate >/dev/null 2>&1"; then
        log_success "✓ Configuration test passed - functions are available"
    else
        log_warning "! Configuration test inconclusive - you may need to restart your shell"
    fi
fi
