#!/usr/bin/env bash
# scripts/editors/zed.sh - Install Zed code editor

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "ZED EDITOR INSTALLATION"

# ============================================================================
# Check if Already Installed
# ============================================================================

if is_command "zed"; then
  log_success "Zed already installed"
  zed --version

  if ask_yes_no "Reinstall or update to latest version?" "n"; then
    log_step "Proceeding with installation..."
  else
    exit 0
  fi
fi

# ============================================================================
# Install Zed
# ============================================================================

log_header "Installing Zed"

if is_macos; then
  log_info "Detected macOS (supports both Apple Silicon and Intel)"

  # Prefer Homebrew if available
  if is_command "brew"; then
    log_step "Installing via Homebrew..."
    brew install --cask zed
  else
    log_error "Homebrew not found"
    log_info "Please install Homebrew first or download Zed from:"
    echo "  https://zed.dev/download"
    exit 1
  fi

elif is_linux; then
  log_info "Detected Linux"
  log_info "Supports: x86_64 and AArch64 (Ubuntu, Arch, Debian, RedHat, CentOS, Fedora)"

  log_step "Installing via official installer..."
  curl -f https://zed.dev/install.sh | sh

else
  log_error "Unsupported operating system"
  exit 1
fi

# ============================================================================
# Verify Installation
# ============================================================================

log_header "Verifying Installation"

# Reload PATH for Linux installations
if is_linux; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if is_command "zed"; then
  log_success "Zed installed successfully!"

  # Show version
  newline
  zed --version

else
  log_error "Zed installation failed"
  log_info "Try restarting your terminal and running: zed --version"
  exit 1
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Zed installation complete!"
newline

echo "Zed features:"
echo "  " High-performance code editor built in Rust"
echo "  " AI-powered coding with built-in assistant"
echo "  " Real-time collaboration"
echo "  " Multi-buffer and multi-cursor editing"
echo "  " Native performance and battery efficiency"
echo "  " Vim mode support"
echo ""
echo "Common commands:"
echo "  zed .               # Open current directory"
echo "  zed file.txt        # Open a file"
echo "  zed --new           # New window"
echo "  zed --add path      # Add to current workspace"
echo "  zed --version       # Show version"
echo "  zed --uninstall     # Uninstall Zed"
echo ""
echo "Next steps:"
echo "  1. Launch Zed: zed"
echo "  2. Configure settings: Zed > Settings"
echo "  3. Install extensions: Zed > Extensions"
echo "  4. Enable Vim mode (optional): Settings > Vim Mode"
echo ""
echo "Updates:"
echo "  " Zed automatically checks for updates"
if is_macos && is_command "brew"; then
  echo "  " Update via Homebrew: brew upgrade zed"
fi
echo ""
echo "Documentation: https://zed.dev/docs"
echo "Keyboard shortcuts: Cmd+K Cmd+S (macOS) or Ctrl+K Ctrl+S (Linux)"
