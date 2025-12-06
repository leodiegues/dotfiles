#!/usr/bin/env bash
# libs/init.sh - Initialize all library functions
# Source this file to load all utility functions

# Get the directory where this script is located
LIBS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LIBS_DIR

# Source all library modules
# shellcheck source=./os-detect.sh
source "$LIBS_DIR/os-detect.sh"

# shellcheck source=./logger.sh
source "$LIBS_DIR/logger.sh"

# shellcheck source=./utils.sh
source "$LIBS_DIR/utils.sh"

# shellcheck source=./backup.sh
source "$LIBS_DIR/backup.sh"

# shellcheck source=./package.sh
source "$LIBS_DIR/package.sh"

# ============================================================================
# Initialization Message (optional, can be disabled with QUIET=1)
# ============================================================================

if [ "${QUIET:-0}" != "1" ] && [ "${DEBUG:-0}" = "1" ]; then
  log_debug "Dotfiles libraries loaded"
  log_debug "  OS: $OS"
  log_debug "  Package Manager: $PKG_MANAGER"
  log_debug "  Architecture: $ARCH"
fi
