#!/usr/bin/env bash
# libs/font-functions.sh - Font installation functions

# Ensure FONTS_DIR is set
FONTS_DIR="${FONTS_DIR:-$HOME/.local/share/fonts}"

# ============================================================================
# Google Fonts Installation
# ============================================================================

install_google_font() {
  local font_name="$1"

  if [ -z "$font_name" ]; then
    log_error "Font name required"
    echo "Usage: install_google_font \"Font Name\""
    echo "Example: install_google_font \"Roboto\""
    return 1
  fi

  log_header "Installing Google Font: $font_name"

  # Create fonts directory
  ensure_dir "$FONTS_DIR"

  # Convert font name to URL format (spaces to +)
  local font_url_name="${font_name// /+}"
  local download_url="https://fonts.google.com/download?family=${font_url_name}"

  # Create temporary directory
  local temp_dir=$(mktemp -d)
  local zip_file="$temp_dir/${font_name}.zip"

  log_step "Downloading $font_name from Google Fonts..."

  # Download font
  if curl -L "$download_url" -o "$zip_file" 2>/dev/null; then
    log_step "Extracting font files..."

    # Extract to fonts directory
    unzip -q -o "$zip_file" -d "$FONTS_DIR/" "*.ttf" "*.otf" 2>/dev/null || {
      log_warning "No TTF/OTF files found, extracting all..."
      unzip -q -o "$zip_file" -d "$temp_dir/"

      # Find and copy font files
      find "$temp_dir" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
    }

    # Cleanup
    rm -rf "$temp_dir"

    # Refresh font cache
    refresh_font_cache

    log_success "$font_name installed successfully"
    return 0
  else
    log_error "Failed to download $font_name"
    log_info "Check if the font name is correct: https://fonts.google.com"
    rm -rf "$temp_dir"
    return 1
  fi
}

# ============================================================================
# Nerd Fonts Installation
# ============================================================================

install_nerd_font() {
  local font_name="$1"
  local version="${2:-latest}"

  if [ -z "$font_name" ]; then
    log_error "Nerd Font name required"
    echo "Usage: install_nerd_font \"FontName\" [version]"
    echo "Example: install_nerd_font \"JetBrainsMono\" \"v3.2.1\""
    echo ""
    echo "Popular Nerd Fonts:"
    echo "  - JetBrainsMono"
    echo "  - FiraCode"
    echo "  - Hack"
    echo "  - Meslo"
    echo "  - RobotoMono"
    echo "  - SourceCodePro"
    echo "  - UbuntuMono"
    echo ""
    echo "Browse all: https://github.com/ryanoasis/nerd-fonts/releases"
    return 1
  fi

  log_header "Installing Nerd Font: $font_name"

  # Create fonts directory
  ensure_dir "$FONTS_DIR"

  # Determine version
  if [ "$version" = "latest" ]; then
    log_step "Fetching latest Nerd Fonts version..."
    version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)

    if [ -z "$version" ]; then
      log_warning "Could not fetch latest version, using v3.2.1"
      version="v3.2.1"
    else
      log_info "Latest version: $version"
    fi
  fi

  # Construct download URL
  local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font_name}.zip"

  # Create temporary directory
  local temp_dir=$(mktemp -d)
  local zip_file="$temp_dir/${font_name}.zip"

  log_step "Downloading $font_name ${version}..."

  # Download font
  if curl -L "$download_url" -o "$zip_file" 2>/dev/null; then
    log_step "Extracting font files..."

    # Extract to fonts directory (exclude Windows compatible fonts)
    unzip -q -o "$zip_file" -d "$FONTS_DIR/" -x "*Windows Compatible*" 2>/dev/null

    # Cleanup
    rm -rf "$temp_dir"

    # Refresh font cache
    refresh_font_cache

    log_success "$font_name Nerd Font installed successfully"
    return 0
  else
    log_error "Failed to download $font_name"
    log_info "Check available fonts: https://github.com/ryanoasis/nerd-fonts/releases"
    rm -rf "$temp_dir"
    return 1
  fi
}

# ============================================================================
# GitHub Repository Font Installation
# ============================================================================

install_github_font() {
  local repo="$1"
  local font_path="${2:-*.ttf}"
  local version="${3:-latest}"

  if [ -z "$repo" ]; then
    log_error "GitHub repository required"
    echo "Usage: install_github_font \"owner/repo\" [font_path] [version]"
    echo "Example: install_github_font \"tonsky/FiraCode\" \"distr/ttf/*.ttf\" \"latest\""
    echo "Example: install_github_font \"microsoft/cascadia-code\" \"*.ttf\" \"v2111.01\""
    return 1
  fi

  log_header "Installing font from GitHub: $repo"

  # Create fonts directory
  ensure_dir "$FONTS_DIR"

  # Extract owner and repo name
  local owner=$(echo "$repo" | cut -d'/' -f1)
  local repo_name=$(echo "$repo" | cut -d'/' -f2)

  # Create temporary directory
  local temp_dir=$(mktemp -d)
  local clone_dir="$temp_dir/$repo_name"

  log_step "Cloning repository..."

  # Clone repository
  if [ "$version" = "latest" ]; then
    if git clone --depth 1 "https://github.com/${repo}.git" "$clone_dir" 2>/dev/null; then
      log_step "Repository cloned successfully"
    else
      log_error "Failed to clone repository"
      rm -rf "$temp_dir"
      return 1
    fi
  else
    if git clone --depth 1 --branch "$version" "https://github.com/${repo}.git" "$clone_dir" 2>/dev/null; then
      log_step "Repository cloned successfully (version: $version)"
    else
      log_error "Failed to clone repository at version $version"
      rm -rf "$temp_dir"
      return 1
    fi
  fi

  log_step "Searching for font files: $font_path"

  # Find and copy font files
  local font_count=0

  # Handle glob patterns
  if [[ "$font_path" == *"*"* ]]; then
    # Pattern contains wildcard
    while IFS= read -r -d '' font_file; do
      cp "$font_file" "$FONTS_DIR/"
      log_info "Copied: $(basename "$font_file")"
      ((font_count++))
    done < <(find "$clone_dir" -path "*/$font_path" -print0 2>/dev/null)
  else
    # Exact path
    if [ -f "$clone_dir/$font_path" ]; then
      cp "$clone_dir/$font_path" "$FONTS_DIR/"
      log_info "Copied: $(basename "$font_path")"
      ((font_count++))
    elif [ -d "$clone_dir/$font_path" ]; then
      # Directory - copy all fonts inside
      find "$clone_dir/$font_path" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
      font_count=$(find "$clone_dir/$font_path" -type f \( -name "*.ttf" -o -name "*.otf" \) | wc -l)
    fi
  fi

  # Cleanup
  rm -rf "$temp_dir"

  if [ $font_count -eq 0 ]; then
    log_error "No font files found matching: $font_path"
    log_info "Check the repository structure: https://github.com/${repo}"
    return 1
  fi

  # Refresh font cache
  refresh_font_cache

  log_success "Installed $font_count font file(s) from $repo"
  return 0
}

# ============================================================================
# Helper Functions
# ============================================================================

refresh_font_cache() {
  log_step "Refreshing font cache..."

  if is_linux; then
    if command -v fc-cache &>/dev/null; then
      fc-cache -fv "$FONTS_DIR" &>/dev/null
      log_success "Font cache refreshed"
    else
      log_warning "fc-cache not found, font cache not refreshed"
    fi
  elif is_macos; then
    # macOS doesn't need manual cache refresh
    log_info "macOS will refresh font cache automatically"
  fi
}

list_installed_fonts() {
  if [ ! -d "$FONTS_DIR" ]; then
    log_info "No fonts directory found: $FONTS_DIR"
    return 0
  fi

  log_header "Installed Fonts"

  local font_count=$(find "$FONTS_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) | wc -l)

  if [ "$font_count" -eq 0 ]; then
    log_info "No fonts installed in $FONTS_DIR"
    return 0
  fi

  echo "Location: $FONTS_DIR"
  echo "Total fonts: $font_count"
  echo ""

  # Group by font family (crude grouping by filename prefix)
  find "$FONTS_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec basename {} \; |
    sed 's/-.*//' |
    sort -u |
    while read -r family; do
      local count=$(find "$FONTS_DIR" -name "${family}*" | wc -l)
      echo "  • $family ($count file(s))"
    done
}

remove_font_family() {
  local family="$1"

  if [ -z "$family" ]; then
    log_error "Font family name required"
    echo "Usage: remove_font_family \"FamilyName\""
    return 1
  fi

  if [ ! -d "$FONTS_DIR" ]; then
    log_error "Fonts directory not found: $FONTS_DIR"
    return 1
  fi

  log_warning "Removing font family: $family"

  local files_to_remove=$(find "$FONTS_DIR" -name "${family}*" -type f)
  local count=$(echo "$files_to_remove" | wc -l)

  if [ "$count" -eq 0 ]; then
    log_info "No fonts found matching: $family"
    return 0
  fi

  echo "Files to remove:"
  echo "$files_to_remove" | while read -r file; do
    echo "  - $(basename "$file")"
  done

  if ask_yes_no "Remove these $count file(s)?"; then
    echo "$files_to_remove" | while read -r file; do
      rm "$file"
    done

    refresh_font_cache
    log_success "Removed $count font file(s)"
  else
    log_info "Cancelled"
  fi
}

# ============================================================================
# Example Usage (commented out)
# ============================================================================

# To use these functions in a script:
#
# source "$DOTFILES/libs/init.sh"
# source "$DOTFILES/libs/font-functions.sh"
#
# # Install Google Fonts
# install_google_font "Roboto"
# install_google_font "Open Sans"
#
# # Install Nerd Fonts
# install_nerd_font "JetBrainsMono"
# install_nerd_font "FiraCode" "v3.2.1"
#
# # Install from GitHub
# install_github_font "tonsky/FiraCode" "distr/ttf/*.ttf"
# install_github_font "be5invis/Iosevka" "*.ttc" "v31.0.0"
#
# # List installed fonts
# list_installed_fonts
#
# # Remove a font family
# remove_font_family "JetBrainsMono"
