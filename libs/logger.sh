#!/usr/bin/env bash
# libs/logger.sh - Colored logging and output functions

# ============================================================================
# Color Definitions
# ============================================================================

# Regular colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'

# Bold colors
readonly BOLD_RED='\033[1;31m'
readonly BOLD_GREEN='\033[1;32m'
readonly BOLD_YELLOW='\033[1;33m'
readonly BOLD_BLUE='\033[1;34m'
readonly BOLD_MAGENTA='\033[1;35m'
readonly BOLD_CYAN='\033[1;36m'
readonly BOLD_WHITE='\033[1;37m'

# Reset
readonly RESET='\033[0m'

# ============================================================================
# Logging Functions
# ============================================================================

log_info() {
  echo -e "${BLUE}ℹ${RESET}  $*"
}

log_success() {
  echo -e "${GREEN}✓${RESET}  $*"
}

log_warning() {
  echo -e "${YELLOW}⚠${RESET}  $*"
}

log_error() {
  echo -e "${RED}✗${RESET}  $*" >&2
}

log_debug() {
  if [ "${DEBUG:-0}" = "1" ]; then
    echo -e "${MAGENTA}🐛${RESET} $*" >&2
  fi
}

log_step() {
  echo -e "${CYAN}→${RESET}  $*"
}

log_header() {
  echo ""
  echo -e "${BOLD_CYAN}▸ $*${RESET}"
  echo -e "${BOLD_CYAN}$(printf '%.0s─' {1..60})${RESET}"
}

log_subheader() {
  echo ""
  echo -e "${BOLD_WHITE}  ▸ $*${RESET}"
}

# ============================================================================
# Status Indicators
# ============================================================================

show_spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  while ps -p "$pid" &>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

show_progress() {
  local current=$1
  local total=$2
  local width=50
  local percent=$((current * 100 / total))
  local filled=$((width * current / total))
  local empty=$((width - filled))

  printf "\r["
  printf "%${filled}s" | tr ' ' '▓'
  printf "%${empty}s" | tr ' ' '░'
  printf "] %3d%%" "$percent"

  if [ "$current" -eq "$total" ]; then
    echo ""
  fi
}

# ============================================================================
# Formatted Output
# ============================================================================

print_banner() {
  local text="$1"
  local width=60
  local padding=$(((width - ${#text}) / 2))

  echo ""
  echo -e "${BOLD_CYAN}$(printf '%.0s═' $(seq 1 $width))${RESET}"
  echo -e "${BOLD_CYAN}$(printf '%*s' $padding)${text}${RESET}"
  echo -e "${BOLD_CYAN}$(printf '%.0s═' $(seq 1 $width))${RESET}"
  echo ""
}

print_section() {
  local text="$1"
  echo ""
  echo -e "${BOLD_WHITE}┌──────────────────────────────────────────────────────┐${RESET}"
  echo -e "${BOLD_WHITE}│  ${text}${RESET}"
  echo -e "${BOLD_WHITE}└──────────────────────────────────────────────────────┘${RESET}"
  echo ""
}

print_list_item() {
  local status="$1"
  local text="$2"

  case "$status" in
  success | ok | done)
    echo -e "  ${GREEN}✓${RESET} $text"
    ;;
  error | fail | failed)
    echo -e "  ${RED}✗${RESET} $text"
    ;;
  warning | warn)
    echo -e "  ${YELLOW}⚠${RESET} $text"
    ;;
  info)
    echo -e "  ${BLUE}ℹ${RESET} $text"
    ;;
  pending | todo)
    echo -e "  ${CYAN}○${RESET} $text"
    ;;
  *)
    echo -e "  • $text"
    ;;
  esac
}

# ============================================================================
# Interactive Prompts
# ============================================================================

prompt_info() {
  echo -e "${BLUE}❯${RESET} $*"
}

prompt_success() {
  echo -e "${GREEN}❯${RESET} $*"
}

prompt_warning() {
  echo -e "${YELLOW}❯${RESET} $*"
}

prompt_error() {
  echo -e "${RED}❯${RESET} $*"
}

# ============================================================================
# Tables
# ============================================================================

print_table_row() {
  local col1="$1"
  local col2="$2"
  printf "  %-30s %s\n" "$col1" "$col2"
}

print_key_value() {
  local key="$1"
  local value="$2"
  echo -e "  ${BOLD_WHITE}${key}:${RESET} $value"
}

# ============================================================================
# Utility Functions
# ============================================================================

hr() {
  local char="${1:-─}"
  local width="${2:-60}"
  printf '%*s\n' "$width" | tr ' ' "$char"
}

newline() {
  echo ""
}

clear_line() {
  echo -ne "\033[2K\r"
}

# ============================================================================
# Command Output Formatting
# ============================================================================

run_with_log() {
  local cmd="$1"
  local description="$2"

  log_step "$description"

  if [ "${VERBOSE:-0}" = "1" ]; then
    eval "$cmd"
  else
    eval "$cmd" &>/dev/null
  fi

  local exit_code=$?

  if [ $exit_code -eq 0 ]; then
    clear_line
    log_success "$description"
  else
    clear_line
    log_error "$description (exit code: $exit_code)"
  fi

  return $exit_code
}

# ============================================================================
# Example Usage (commented out)
# ============================================================================

# To use this in your scripts:
#
# source "$(dirname "$0")/../libs/logger.sh"
#
# log_header "Installing Packages"
# log_step "Installing neovim..."
# log_success "Neovim installed successfully"
# log_error "Failed to install package"
# log_warning "Configuration already exists"
#
# print_banner "DOTFILES INSTALLER"
# print_list_item "success" "Zsh installed"
# print_list_item "error" "Failed to install Docker"
# print_key_value "OS" "macOS"
# print_key_value "Version" "14.1"
