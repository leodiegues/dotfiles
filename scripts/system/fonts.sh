#!/usr/bin/env bash
# scripts/core/fonts.sh - Install fonts for terminal and editor

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"
source "$DOTFILES/libs/font-functions.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "FONTS INSTALLATION"

# Set fonts directory based on OS
if is_macos; then
    export FONTS_DIR="$HOME/Library/Fonts"
elif is_linux; then
    export FONTS_DIR="$HOME/.local/share/fonts"
else
    log_error "Unsupported operating system"
    exit 1
fi

log_info "Installing fonts to: $FONTS_DIR"

# Ensure fonts directory exists
ensure_dir "$FONTS_DIR"

# ============================================================================
# Install Dependencies
# ============================================================================

log_header "Checking Dependencies"

if is_linux; then
    pkg_install_if_missing "curl"
    pkg_install_if_missing "unzip"
fi

# ============================================================================
# Install Nerd Fonts
# ============================================================================

log_header "Installing Nerd Fonts"

# Nerd Fonts
install_nerd_font "NerdFontsSymbolsOnly" "v3.2.1"
install_nerd_font "JetBrainsMono" "v3.2.1"
install_nerd_font "FiraCode" "v3.2.1"
install_nerd_font "Meslo" "v3.2.1"

# ============================================================================
# Install Comic Code Font
# ============================================================================

log_header "Installing Comic Code Font"

# Comic Code from GitHub
install_github_font "tabatkins/comic-code" "Comic Code.ttf" "latest" || {
    log_warning "Comic Code installation failed - may require manual installation"
}

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Font installation complete!"
log_info "Restart your terminal and applications to use the new fonts"
