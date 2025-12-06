#!/usr/bin/env bash
# libs/os-detect.sh - Operating system and package manager detection

# ============================================================================
# OS Detection
# ============================================================================

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$ID"
  else
    echo "unknown"
  fi
}

detect_os_version() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sw_vers -productVersion
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$VERSION_ID"
  else
    echo "unknown"
  fi
}

detect_os_family() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "darwin"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID_LIKE" in
    *debian*) echo "debian" ;;
    *rhel* | *fedora*) echo "redhat" ;;
    *arch*) echo "arch" ;;
    *) echo "$ID" ;;
    esac
  else
    echo "unknown"
  fi
}

# ============================================================================
# Package Manager Detection
# ============================================================================

detect_package_manager() {
  if command -v brew &>/dev/null; then
    echo "brew"
  elif command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v zypper &>/dev/null; then
    echo "zypper"
  else
    echo "unknown"
  fi
}

# ============================================================================
# Architecture Detection
# ============================================================================

detect_arch() {
  local arch
  arch=$(uname -m)

  case "$arch" in
  x86_64 | amd64)
    echo "x86_64"
    ;;
  aarch64 | arm64)
    echo "arm64"
    ;;
  armv7l)
    echo "armv7"
    ;;
  *)
    echo "$arch"
    ;;
  esac
}

# ============================================================================
# OS Specific Checks
# ============================================================================

is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

is_linux() {
  [[ "$OSTYPE" == "linux-gnu"* ]]
}

is_ubuntu() {
  [ -f /etc/os-release ] && grep -q "ID=ubuntu" /etc/os-release
}

is_fedora() {
  [ -f /etc/os-release ] && grep -q "ID=fedora" /etc/os-release
}

is_debian() {
  [ -f /etc/os-release ] && grep -q "ID=debian" /etc/os-release
}

is_arch() {
  [ -f /etc/os-release ] && grep -q "ID=arch" /etc/os-release
}

is_wsl() {
  [ -n "$WSL_DISTRO_NAME" ] || grep -qi microsoft /proc/version 2>/dev/null
}

# ============================================================================
# Display System Information
# ============================================================================

show_system_info() {
  echo "System Information:"
  echo "  OS:              $(detect_os)"
  echo "  OS Version:      $(detect_os_version)"
  echo "  OS Family:       $(detect_os_family)"
  echo "  Package Manager: $(detect_package_manager)"
  echo "  Architecture:    $(detect_arch)"

  if is_wsl; then
    echo "  WSL:             Yes"
  fi
}

# ============================================================================
# Export Detected Values (for sourcing)
# ============================================================================

export OS=$(detect_os)
export OS_VERSION=$(detect_os_version)
export OS_FAMILY=$(detect_os_family)
export PKG_MANAGER=$(detect_package_manager)
export ARCH=$(detect_arch)

# If WSL, detect and export
if is_wsl; then
  export IS_WSL=true
else
  export IS_WSL=false
fi
