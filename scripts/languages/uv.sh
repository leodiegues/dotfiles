#!/usr/bin/env bash
# scripts/languages/uv.sh - Install uv (Python package and project manager)

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "UV INSTALLATION"

# ============================================================================
# Check if Already Installed
# ============================================================================

if is_command "uv"; then
  log_success "uv already installed"
  uv --version

  if ask_yes_no "Upgrade to latest version?" "n"; then
    log_step "Upgrading uv..."
    uv self update
    log_success "uv upgraded successfully"
  fi

  exit 0
fi

# ============================================================================
# Install uv
# ============================================================================

log_header "Installing uv"

if is_macos; then
  log_info "Detected macOS"

  # Prefer Homebrew if available
  if is_command "brew"; then
    log_step "Installing via Homebrew..."
    brew install uv
  else
    log_step "Installing via official installer..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi

elif is_linux; then
  log_info "Detected Linux"

  log_step "Installing via official installer..."
  curl -LsSf https://astral.sh/uv/install.sh | sh

else
  log_error "Unsupported operating system"
  exit 1
fi

# ============================================================================
# Configure Shell PATH
# ============================================================================

log_header "Configuring Shell"

# uv installs to ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# Check if PATH already configured in .zshrc
ZSHRC="$HOME/.zshrc"

if [ -f "$ZSHRC" ]; then
  if grep -q ".local/bin" "$ZSHRC" && grep -q "PATH" "$ZSHRC"; then
    log_success "PATH already configured in .zshrc"
  else
    log_step "Adding uv to PATH in .zshrc..."

    cat >> "$ZSHRC" << 'EOF'

# uv (Python package manager)
export PATH="$HOME/.local/bin:$PATH"
EOF

    log_success "uv PATH added to .zshrc"
  fi
else
  log_warning ".zshrc not found"
  log_info "Add this line to your shell config:"
  echo '  export PATH="$HOME/.local/bin:$PATH"'
fi

# ============================================================================
# Shell Autocompletion (Optional)
# ============================================================================

if ask_yes_no "Enable shell autocompletion?" "y"; then
  log_step "Enabling zsh autocompletion..."

  if [ -f "$ZSHRC" ]; then
    # Check if already configured
    if grep -q "uv generate-shell-completion" "$ZSHRC"; then
      log_success "Autocompletion already configured"
    else
      cat >> "$ZSHRC" << 'EOF'

# uv shell completion
eval "$(uv generate-shell-completion zsh)"
EOF

      log_success "Autocompletion added to .zshrc"
    fi
  fi
fi

# ============================================================================
# Verify Installation
# ============================================================================

log_header "Verifying Installation"

if is_command "uv"; then
  log_success "uv installed successfully!"

  # Show version
  newline
  uv --version

else
  log_error "uv installation failed"
  log_info "Try restarting your terminal and running: uv --version"
  exit 1
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "uv installation complete!"
newline

echo "What is uv?"
echo "  • Extremely fast Python package and project manager"
echo "  • 10-100x faster than pip"
echo "  • Drop-in replacement for pip, pip-tools, pipx, poetry, pyenv"
echo "  • Written in Rust by Astral (creators of Ruff)"
echo ""
echo "Common commands:"
echo "  uv init          # Create a new project"
echo "  uv add <package> # Add a dependency"
echo "  uv sync          # Install dependencies"
echo "  uv run <cmd>     # Run a command in the project environment"
echo "  uv pip install   # Use as a pip replacement"
echo "  uv python list   # List available Python versions"
echo "  uv self update   # Upgrade uv"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Verify: uv --version"
echo "  3. Create a project: uv init my-project"
echo ""
echo "Documentation: https://docs.astral.sh/uv/"
