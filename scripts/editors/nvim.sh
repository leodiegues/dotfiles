#!/usr/bin/env bash
# scripts/editors/nvim.sh - Install Neovim

set -e

# Get script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source libraries
source "$DOTFILES/libs/init.sh"

# ============================================================================
# Main Installation
# ============================================================================

print_banner "NEOVIM INSTALLATION"

# ============================================================================
# Check if Already Installed
# ============================================================================

if is_command "nvim"; then
  log_success "Neovim already installed"
  nvim --version | head -n 1

  if ask_yes_no "Upgrade to latest version?" "n"; then
    log_step "Upgrading Neovim..."
  else
    exit 0
  fi
fi

# ============================================================================
# Install Neovim
# ============================================================================

log_header "Installing Neovim"

if is_macos; then
  log_info "Detected macOS"

  if is_command "brew"; then
    log_step "Installing via Homebrew..."
    brew install neovim
  else
    log_error "Homebrew not found"
    log_info "Please install Homebrew first or download Neovim from:"
    echo "  https://github.com/neovim/neovim/releases"
    exit 1
  fi

elif is_linux; then
  log_info "Detected Linux"

  if is_ubuntu || is_debian; then
    log_step "Installing via apt..."
    sudo apt-get update
    sudo apt-get install -y neovim python3-neovim

  elif is_command "pacman"; then
    log_step "Installing via pacman (Arch Linux)..."
    sudo pacman -S --noconfirm neovim python-pynvim

  elif is_command "dnf"; then
    log_step "Installing via dnf (Fedora)..."
    sudo dnf install -y neovim python3-neovim

  elif is_command "yum"; then
    log_step "Installing via yum (RHEL/CentOS)..."
    sudo yum install -y neovim python3-neovim

  else
    log_error "Unsupported Linux distribution"
    log_info "Please install manually from:"
    echo "  https://github.com/neovim/neovim/releases"
    exit 1
  fi

else
  log_error "Unsupported operating system"
  exit 1
fi

# ============================================================================
# Verify Installation
# ============================================================================

log_header "Verifying Installation"

if is_command "nvim"; then
  log_success "Neovim installed successfully!"

  # Show version
  newline
  nvim --version | head -n 3

else
  log_error "Neovim installation failed"
  log_info "Try restarting your terminal and running: nvim --version"
  exit 1
fi

# ============================================================================
# Summary
# ============================================================================

newline
log_success "Neovim installation complete!"
newline

echo "Neovim features:"
echo "  • Hyperextensible Vim-based text editor"
echo "  • Built-in LSP (Language Server Protocol) support"
echo "  • Lua configuration and scripting"
echo "  • Async job control and plugin architecture"
echo "  • Modern terminal features and UI"
echo "  • Fully compatible with Vim plugins and scripts"
echo ""
echo "Common commands:"
echo "  nvim                # Open Neovim"
echo "  nvim file.txt       # Open a file"
echo "  nvim -d f1 f2       # Diff mode"
echo "  nvim --version      # Show version"
echo ""
echo "Configuration:"
echo "  • Config location: ~/.config/nvim/init.vim (Vimscript)"
echo "  •                  ~/.config/nvim/init.lua (Lua)"
echo "  • Check health: :checkhealth"
echo ""
echo "Next steps:"
echo "  1. Launch Neovim: nvim"
echo "  2. Learn basics: nvim +Tutor"
echo "  3. Check health: nvim +checkhealth"
if is_macos && is_command "brew"; then
  echo "  4. Update: brew upgrade neovim"
elif is_ubuntu || is_debian; then
  echo "  4. Update: sudo apt-get update && sudo apt-get upgrade neovim"
fi
echo ""
echo "Resources:"
echo "  • Documentation: :help"
echo "  • Website: https://neovim.io"
echo "  • GitHub: https://github.com/neovim/neovim"
echo "  • Awesome Neovim: https://github.com/rockerBOO/awesome-neovim"
