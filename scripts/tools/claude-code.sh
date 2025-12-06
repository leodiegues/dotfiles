#!/usr/bin/env bash
# scripts/tools/claude-code.sh - Install Claude Code CLI

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "CLAUDE CODE INSTALLATION"

# ============================================================================
# Check if Already Installed
# ============================================================================

if is_command "claude"; then
  log_success "Claude Code already installed"
  claude --version

  if ask_yes_no "Run update check?" "y"; then
    log_step "Checking for updates..."
    claude update || log_info "Update check complete"
  fi

  exit 0
fi

# ============================================================================
# Install Claude Code
# ============================================================================

log_header "Installing Claude Code"

if is_macos; then
  log_info "Detected macOS"

  # Prefer Homebrew if available
  if is_command "brew"; then
    log_step "Installing via Homebrew..."
    brew install --cask claude-code
  else
    log_step "Installing via official installer..."
    curl -fsSL https://claude.ai/install.sh | bash
  fi

elif is_linux; then
  log_info "Detected Linux"

  # Check system requirements
  if is_ubuntu || is_debian; then
    # Check Ubuntu/Debian version
    version_id=$(lsb_release -rs 2>/dev/null || echo "0")
    major_version=$(echo "$version_id" | cut -d. -f1)

    if [ "$major_version" -lt 20 ] && is_ubuntu; then
      log_warning "Claude Code requires Ubuntu 20.04 or higher"
      log_warning "Current version: $version_id"
    fi
  fi

  log_step "Installing via official installer..."
  curl -fsSL https://claude.ai/install.sh | bash

else
  log_error "Unsupported operating system"
  log_info "Supported: macOS 10.15+, Ubuntu 20.04+, Debian 10+, WSL"
  exit 1
fi

# ============================================================================
# Verify Installation
# ============================================================================

log_header "Verifying Installation"

# Reload PATH (installation adds to shell config)
export PATH="$HOME/.local/bin:$PATH"

if is_command "claude"; then
  log_success "Claude Code installed successfully!"

  newline
  claude --version

  # Run diagnostics
  newline
  log_step "Running diagnostics..."
  claude doctor || log_warning "Diagnostics check completed with warnings"

else
  log_error "Claude Code installation failed"
  log_info "Try restarting your terminal and running: claude --version"
  exit 1
fi

# ============================================================================
# Authentication Setup
# ============================================================================

log_header "Authentication Setup"

newline
echo "Claude Code requires authentication to work."
echo ""
echo "Authentication options:"
echo "  1. Claude Console (console.anthropic.com) - Requires active billing"
echo "  2. Claude App (claude.com) - Requires Pro or Max subscription"
echo "  3. Enterprise platforms - Amazon Bedrock, Google Vertex AI, etc."
echo ""

if ask_yes_no "Set up authentication now?" "y"; then
  log_info "Follow the prompts to authenticate..."
  newline

  # Try to authenticate
  claude auth login || log_warning "Authentication can be completed later"
else
  log_info "You can authenticate later by running: claude auth login"
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Claude Code installation complete!"
newline

echo "Claude Code features:"
echo "  • AI-powered coding assistant CLI"
echo "  • Natural language to code generation"
echo "  • Code editing and refactoring"
echo "  • Test generation and debugging"
echo "  • Multi-file project understanding"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Navigate to a project: cd your-awesome-project"
echo "  3. Start Claude Code: claude"
echo "  4. Check status: claude doctor"
echo ""
echo "Configuration:"
echo "  • Auto-updates: Enabled by default"
echo "  • Disable: export DISABLE_AUTOUPDATER=1"
echo "  • Update manually: claude update"
echo ""
echo "Documentation: https://code.claude.com/docs"
echo "Get help: claude --help"
