#!/usr/bin/env bash
# libs/utils.sh - Core utility functions for dotfiles management

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# ============================================================================
# Configuration Linking Functions
# ============================================================================

link_config() {
  local src="$1"
  local dest="$2"
  local backup

  # Validate inputs
  if [ -z "$src" ] || [ -z "$dest" ]; then
    echo "❌ Error: link_config requires source and destination"
    return 1
  fi

  if [ ! -e "$src" ]; then
    echo "❌ Error: Source does not exist: $src"
    return 1
  fi

  # Backup existing file/dir if not a symlink
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup="${dest}.backup.$(date +%s)"
    echo "📦 Backing up existing $dest → $backup"
    mv "$dest" "$backup"
  fi

  # Remove broken symlink
  if [ -L "$dest" ] && [ ! -e "$dest" ]; then
    rm "$dest"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  # Create symlink
  ln -sf "$src" "$dest"
  echo "🔗 Linked $dest → $src"
}

unlink_config() {
  local dest="$1"
  if [ -L "$dest" ]; then
    rm "$dest"
    echo "🗑️  Removed symlink $dest"
    return 0
  else
    echo "⚠️  Not a symlink: $dest"
    return 1
  fi
}

# ============================================================================
# Installation Helper Functions
# ============================================================================

install_if_missing() {
  local cmd="$1"
  local install_fn="$2"

  if ! command -v "$cmd" &>/dev/null; then
    echo "📥 Installing $cmd..."
    if [ -n "$install_fn" ]; then
      $install_fn
    else
      echo "❌ Error: No install function provided"
      return 1
    fi
  else
    echo "✅ $cmd already installed"
    return 0
  fi
}

ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    echo "📁 Created directory: $dir"
  fi
}

# ============================================================================
# User Interaction Functions
# ============================================================================

ask_yes_no() {
  local prompt="$1"
  local default="${2:-n}"
  local response

  if [ "$default" = "y" ]; then
    prompt="$prompt [Y/n] "
  else
    prompt="$prompt [y/N] "
  fi

  read -r -p "$prompt" response
  response=${response:-$default}

  case "$response" in
  [yY][eE][sS] | [yY]) return 0 ;;
  *) return 1 ;;
  esac
}

ask_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  local choice

  echo "$prompt"
  for i in "${!options[@]}"; do
    echo "  $((i + 1))) ${options[$i]}"
  done

  while true; do
    read -r -p "Enter choice [1-${#options[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
      return $((choice - 1))
    fi
    echo "❌ Invalid choice. Try again."
  done
}

# ============================================================================
# Git/Dotfiles Management Functions
# ============================================================================

dotfiles_status() {
  cd "$DOTFILES" || exit
  git status
}

dotfiles_commit() {
  cd "$DOTFILES" || exit
  git add -A
  git commit -m "${1:-Update configs}"
  git push
}

dotfiles_pull() {
  cd "$DOTFILES" || exit
  git pull
  echo "✅ Configs updated from remote"
}

# ============================================================================
# Validation Functions
# ============================================================================

is_command() {
  command -v "$1" &>/dev/null
}

is_root() {
  [ "$EUID" -eq 0 ]
}

require_root() {
  if ! is_root; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
  fi
}

check_internet() {
  if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
    echo "❌ No internet connection detected"
    return 1
  fi
  return 0
}
