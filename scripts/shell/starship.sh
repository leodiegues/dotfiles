#!/usr/bin/env bash
# scripts/shell/starship.sh - Install Starship cross-shell prompt

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "STARSHIP INSTALLATION"

# ============================================================================
# Install Starship
# ============================================================================

log_header "Installing Starship"

if is_command "starship"; then
  log_success "Starship already installed"
  starship --version
else
  if is_macos; then
    log_step "Installing via Homebrew..."
    pkg_install starship
  elif is_linux; then
    # Check if available in package manager
    if is_ubuntu && [ "$(lsb_release -rs | cut -d. -f1)" -ge 25 ]; then
      log_step "Installing via apt (Ubuntu 25.04+)..."
      pkg_update
      pkg_install starship
    elif is_fedora; then
      log_step "Installing via dnf..."
      pkg_install starship
    else
      log_step "Installing via official installer..."
      log_warning "This will prompt for sudo password"

      # Download and run official installer
      curl -sS https://starship.rs/install.sh | sh
    fi
  else
    log_error "Unsupported operating system"
    exit 1
  fi

  log_success "Starship installed successfully"
fi

# ============================================================================
# Link Configuration
# ============================================================================

log_header "Configuring Starship"

# Link starship config
link_config "$DOTFILES/configs/starship/starship.toml" "$HOME/.config/starship.toml"

# ============================================================================
# Shell Integration
# ============================================================================

log_header "Shell Integration"

ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
  # Check if already integrated
  if grep -q "starship init zsh" "$ZSHRC"; then
    log_success "Starship already integrated in .zshrc"
  else
    log_step "Adding Starship initialization to .zshrc..."

    # Add to .zshrc
    cat >> "$ZSHRC" << 'EOF'

# Starship prompt
eval "$(starship init zsh)"
EOF

    log_success "Starship initialization added to .zshrc"
  fi
else
  log_warning ".zshrc not found at $ZSHRC"
  log_info "Add this line to your shell config:"
  echo '  eval "$(starship init zsh)"'
fi

# ============================================================================
# Verify Nerd Fonts
# ============================================================================

log_header "Prerequisites Check"

log_info "Starship requires a Nerd Font for icons"
log_step "Checking for Nerd Fonts..."

if [ -d "$HOME/.local/share/fonts" ] && find "$HOME/.local/share/fonts" -name "*Nerd*" -o -name "*NF*" | grep -q .; then
  log_success "Nerd Fonts detected"
elif [ -d "$HOME/Library/Fonts" ] && find "$HOME/Library/Fonts" -name "*Nerd*" -o -name "*NF*" | grep -q .; then
  log_success "Nerd Fonts detected"
else
  log_warning "Nerd Fonts not detected"
  log_info "Install Nerd Fonts with: ./scripts/core/fonts.sh"
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Starship installation complete!"
newline

echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Ensure your terminal is using a Nerd Font"
echo "  3. Customize config at: ~/.config/starship.toml"
echo ""
echo "Documentation: https://starship.rs"
