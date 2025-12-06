#!/usr/bin/env bash
# libs/package.sh - Package manager abstraction layer

# Source OS detection if not already loaded
if [ -z "$PKG_MANAGER" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./os-detect.sh
  source "$SCRIPT_DIR/os-detect.sh"
fi

# ============================================================================
# Package Installation
# ============================================================================

pkg_update() {
  echo "📦 Updating package lists..."

  case "$PKG_MANAGER" in
  apt)
    sudo apt update
    ;;
  dnf)
    sudo dnf check-update || true
    ;;
  yum)
    sudo yum check-update || true
    ;;
  brew)
    brew update
    ;;
  pacman)
    sudo pacman -Sy
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

pkg_install() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    echo "❌ No packages specified"
    return 1
  fi

  echo "📥 Installing packages: ${packages[*]}"

  case "$PKG_MANAGER" in
  apt)
    sudo apt install -y "${packages[@]}"
    ;;
  dnf)
    sudo dnf install -y "${packages[@]}"
    ;;
  yum)
    sudo yum install -y "${packages[@]}"
    ;;
  brew)
    brew install "${packages[@]}"
    ;;
  pacman)
    sudo pacman -S --noconfirm "${packages[@]}"
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

pkg_install_if_missing() {
  local package="$1"
  local command="${2:-$package}"

  if command -v "$command" &>/dev/null; then
    echo "✅ $package already installed"
    return 0
  fi

  pkg_install "$package"
}

# ============================================================================
# Package Removal
# ============================================================================

pkg_remove() {
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    echo "❌ No packages specified"
    return 1
  fi

  echo "🗑️  Removing packages: ${packages[*]}"

  case "$PKG_MANAGER" in
  apt)
    sudo apt remove -y "${packages[@]}"
    ;;
  dnf)
    sudo dnf remove -y "${packages[@]}"
    ;;
  yum)
    sudo yum remove -y "${packages[@]}"
    ;;
  brew)
    brew uninstall "${packages[@]}"
    ;;
  pacman)
    sudo pacman -R --noconfirm "${packages[@]}"
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Package Search
# ============================================================================

pkg_search() {
  local query="$1"

  if [ -z "$query" ]; then
    echo "❌ No search query specified"
    return 1
  fi

  case "$PKG_MANAGER" in
  apt)
    apt search "$query"
    ;;
  dnf)
    dnf search "$query"
    ;;
  yum)
    yum search "$query"
    ;;
  brew)
    brew search "$query"
    ;;
  pacman)
    pacman -Ss "$query"
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Package Info
# ============================================================================

pkg_info() {
  local package="$1"

  if [ -z "$package" ]; then
    echo "❌ No package specified"
    return 1
  fi

  case "$PKG_MANAGER" in
  apt)
    apt show "$package"
    ;;
  dnf)
    dnf info "$package"
    ;;
  yum)
    yum info "$package"
    ;;
  brew)
    brew info "$package"
    ;;
  pacman)
    pacman -Si "$package"
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Package Upgrade
# ============================================================================

pkg_upgrade() {
  echo "⬆️  Upgrading all packages..."

  case "$PKG_MANAGER" in
  apt)
    sudo apt update && sudo apt upgrade -y
    ;;
  dnf)
    sudo dnf upgrade -y
    ;;
  yum)
    sudo yum update -y
    ;;
  brew)
    brew update && brew upgrade
    ;;
  pacman)
    sudo pacman -Syu --noconfirm
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Repository Management
# ============================================================================

pkg_add_repo() {
  local repo="$1"

  if [ -z "$repo" ]; then
    echo "❌ No repository specified"
    return 1
  fi

  case "$PKG_MANAGER" in
  apt)
    sudo add-apt-repository -y "$repo"
    sudo apt update
    ;;
  dnf)
    sudo dnf config-manager --add-repo "$repo"
    ;;
  yum)
    sudo yum-config-manager --add-repo "$repo"
    ;;
  brew)
    brew tap "$repo"
    ;;
  *)
    echo "❌ Repository management not supported for: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Cleanup Functions
# ============================================================================

pkg_clean() {
  echo "🧹 Cleaning package cache..."

  case "$PKG_MANAGER" in
  apt)
    sudo apt autoremove -y
    sudo apt clean
    ;;
  dnf)
    sudo dnf autoremove -y
    sudo dnf clean all
    ;;
  yum)
    sudo yum autoremove -y
    sudo yum clean all
    ;;
  brew)
    brew cleanup
    brew autoremove
    ;;
  pacman)
    sudo pacman -Sc --noconfirm
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}

# ============================================================================
# Batch Package Management
# ============================================================================

pkg_install_list() {
  local package_list_file="$1"

  if [ ! -f "$package_list_file" ]; then
    echo "❌ Package list file not found: $package_list_file"
    return 1
  fi

  echo "📦 Installing packages from: $package_list_file"

  while IFS= read -r package; do
    # Skip empty lines and comments
    [[ -z "$package" || "$package" =~ ^# ]] && continue

    pkg_install "$package"
  done <"$package_list_file"
}

# ============================================================================
# OS-Specific Package Name Translation
# ============================================================================

# Some packages have different names across distros
translate_package_name() {
  local package="$1"
  local os="$OS"

  # Add translations as needed
  case "$package" in
  python-dev | python-devel)
    case "$os" in
    ubuntu | debian) echo "python3-dev" ;;
    fedora | rhel) echo "python3-devel" ;;
    *) echo "$package" ;;
    esac
    ;;
  build-essential)
    case "$os" in
    fedora | rhel) echo "gcc gcc-c++ make" ;;
    macos) echo "xcode-select" ;;
    *) echo "$package" ;;
    esac
    ;;
  *)
    echo "$package"
    ;;
  esac
}

# ============================================================================
# Snap/Flatpak Support
# ============================================================================

snap_install() {
  local package="$1"
  local flags="${2:---classic}"

  if ! command -v snap &>/dev/null; then
    echo "❌ Snap not installed"
    return 1
  fi

  echo "📦 Installing snap package: $package"
  sudo snap install "$package" $flags
}

flatpak_install() {
  local package="$1"

  if ! command -v flatpak &>/dev/null; then
    echo "❌ Flatpak not installed"
    return 1
  fi

  echo "📦 Installing flatpak package: $package"
  flatpak install -y flathub "$package"
}

# ============================================================================
# Helper Functions
# ============================================================================

is_package_installed() {
  local package="$1"

  case "$PKG_MANAGER" in
  apt)
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
    ;;
  dnf | yum)
    rpm -q "$package" &>/dev/null
    ;;
  brew)
    brew list "$package" &>/dev/null
    ;;
  pacman)
    pacman -Q "$package" &>/dev/null
    ;;
  *)
    return 1
    ;;
  esac
}

list_installed_packages() {
  case "$PKG_MANAGER" in
  apt)
    dpkg -l | grep "^ii"
    ;;
  dnf | yum)
    rpm -qa
    ;;
  brew)
    brew list
    ;;
  pacman)
    pacman -Q
    ;;
  *)
    echo "❌ Unknown package manager: $PKG_MANAGER"
    return 1
    ;;
  esac
}
