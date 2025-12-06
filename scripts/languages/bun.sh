#!/usr/bin/env bash
# scripts/languages/bun.sh - Install Bun JavaScript runtime

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "BUN INSTALLATION"

# ============================================================================
# Check if Already Installed
# ============================================================================

if is_command "bun"; then
  log_success "Bun already installed"
  bun --version

  if ask_yes_no "Upgrade to latest version?" "n"; then
    log_step "Upgrading Bun..."
    bun upgrade
    log_success "Bun upgraded successfully"
  fi

  exit 0
fi

# ============================================================================
# Install Bun
# ============================================================================

log_header "Installing Bun"

if is_macos; then
  log_info "Detected macOS"

  # Prefer Homebrew if available
  if is_command "brew"; then
    log_step "Installing via Homebrew..."
    brew install bun
  else
    log_step "Installing via official installer..."
    curl -fsSL https://bun.com/install | bash
  fi

elif is_linux; then
  log_info "Detected Linux"

  # Check kernel version (requires 5.6+, minimum 5.1)
  kernel_version=$(uname -r | cut -d. -f1,2)
  kernel_major=$(echo "$kernel_version" | cut -d. -f1)
  kernel_minor=$(echo "$kernel_version" | cut -d. -f2)

  if [ "$kernel_major" -lt 5 ] || ([ "$kernel_major" -eq 5 ] && [ "$kernel_minor" -lt 1 ]); then
    log_error "Bun requires Linux kernel 5.1 or higher (5.6+ recommended)"
    log_error "Current kernel: $(uname -r)"
    exit 1
  fi

  if [ "$kernel_major" -eq 5 ] && [ "$kernel_minor" -lt 6 ]; then
    log_warning "Kernel $(uname -r) detected. Bun recommends 5.6+"
  fi

  log_step "Installing via official installer..."
  curl -fsSL https://bun.com/install | bash

else
  log_error "Unsupported operating system"
  exit 1
fi

# ============================================================================
# Configure Shell PATH
# ============================================================================

log_header "Configuring Shell"

# Bun installs to ~/.bun/bin
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Check if PATH already configured in .zshrc
ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
  if grep -q "BUN_INSTALL" "$ZSHRC"; then
    log_success "Bun PATH already configured in .zshrc"
  else
    log_step "Adding Bun to PATH in .zshrc..."

    cat >> "$ZSHRC" << 'EOF'

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF

    log_success "Bun PATH added to .zshrc"
  fi
else
  log_warning ".zshrc not found"
  log_info "Add these lines to your shell config:"
  echo '  export BUN_INSTALL="$HOME/.bun"'
  echo '  export PATH="$BUN_INSTALL/bin:$PATH"'
fi

# ============================================================================
# Verify Installation
# ============================================================================

log_header "Verifying Installation"

if is_command "bun"; then
  log_success "Bun installed successfully!"

  # Show version
  newline
  bun --version
  bun --revision

else
  log_error "Bun installation failed"
  log_info "Try restarting your terminal and running: bun --version"
  exit 1
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Bun installation complete!"
newline

echo "Bun features:"
echo "  • JavaScript/TypeScript runtime (Node.js alternative)"
echo "  • Built-in bundler, transpiler, and task runner"
echo "  • Fast package manager (npm alternative)"
echo "  • Native TypeScript support"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Verify: bun --version"
echo "  3. Upgrade anytime: bun upgrade"
echo ""
echo "Documentation: https://bun.sh/docs"
