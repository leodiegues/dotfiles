# Dotfiles Libraries

Reusable bash libraries for dotfiles management.

## Quick Start

Source all libraries at once:

```bash
source "$(dirname "$0")/../libs/init.sh"
```

Or source individual libraries:

```bash
source "$(dirname "$0")/../libs/logger.sh"
source "$(dirname "$0")/../libs/utils.sh"
```

## Libraries

### `init.sh`

Master initialization file that sources all other libraries. Use this for convenience.

### `os-detect.sh`

Operating system and package manager detection.

**Exported Variables:**
- `$OS` - Operating system ID (macos, ubuntu, fedora, etc.)
- `$OS_VERSION` - OS version
- `$OS_FAMILY` - OS family (darwin, debian, redhat, etc.)
- `$PKG_MANAGER` - Package manager (brew, apt, dnf, etc.)
- `$ARCH` - System architecture (x86_64, arm64, etc.)
- `$IS_WSL` - true/false if running in WSL

**Functions:**
- `detect_os()` - Returns OS identifier
- `detect_os_version()` - Returns OS version
- `detect_os_family()` - Returns OS family
- `detect_package_manager()` - Returns package manager
- `detect_arch()` - Returns architecture
- `is_macos()` - Check if running macOS
- `is_linux()` - Check if running Linux
- `is_ubuntu()` - Check if running Ubuntu
- `is_fedora()` - Check if running Fedora
- `is_wsl()` - Check if running in WSL
- `show_system_info()` - Display all system info

**Example:**
```bash
source libs/os-detect.sh

if is_macos; then
    echo "Running on macOS"
elif is_ubuntu; then
    echo "Running on Ubuntu"
fi

echo "Package manager: $PKG_MANAGER"
```

### `logger.sh`

Colored output and logging functions.

**Functions:**
- `log_info "message"` - Blue info message
- `log_success "message"` - Green success message
- `log_warning "message"` - Yellow warning message
- `log_error "message"` - Red error message
- `log_debug "message"` - Purple debug message (only if DEBUG=1)
- `log_step "message"` - Cyan step indicator
- `log_header "title"` - Section header
- `log_subheader "title"` - Subsection header
- `print_banner "text"` - Print banner with text
- `print_section "text"` - Print section box
- `print_list_item "status" "text"` - Print list item with status icon
- `print_key_value "key" "value"` - Print key-value pair
- `hr [char] [width]` - Print horizontal rule
- `run_with_log "command" "description"` - Run command with logging

**Example:**
```bash
source libs/logger.sh

log_header "Installing Neovim"
log_step "Downloading neovim..."
# ... do work ...
log_success "Neovim installed successfully"

print_list_item "success" "Zsh configured"
print_list_item "error" "Docker failed to install"
print_list_item "warning" "Config file already exists"
```

### `utils.sh`

Core utility functions for configuration management.

**Variables:**
- `$DOTFILES` - Path to dotfiles directory (default: ~/.dotfiles)

**Configuration Functions:**
- `link_config "source" "destination"` - Create symlink with backup
- `unlink_config "destination"` - Remove symlink

**Installation Functions:**
- `install_if_missing "command" "install_function"` - Install if not present
- `ensure_dir "path"` - Create directory if missing

**User Interaction:**
- `ask_yes_no "prompt" [default]` - Ask yes/no question
- `ask_choice "prompt" "opt1" "opt2" ...` - Multiple choice menu

**Validation:**
- `is_command "command"` - Check if command exists
- `is_root()` - Check if running as root
- `require_root()` - Exit if not root
- `check_internet()` - Check internet connectivity

**Git Functions:**
- `dotfiles_status()` - Show git status
- `dotfiles_commit [message]` - Commit and push changes
- `dotfiles_pull()` - Pull latest changes

**Example:**
```bash
source libs/utils.sh

# Link configuration files
link_config "$DOTFILES/config/zsh/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES/config/nvim" "$HOME/.config/nvim"

# Ask user
if ask_yes_no "Install Docker?"; then
    echo "Installing Docker..."
fi

# Check if command exists
if is_command "nvim"; then
    echo "Neovim is installed"
fi
```

### `backup.sh`

Backup and restore configuration files.

**Variables:**
- `$BACKUP_DIR` - Backup directory (default: ~/.dotfiles-backups)
- `$BACKUP_TIMESTAMP` - Current timestamp for backups

**Backup Functions:**
- `backup_file "file" [name]` - Backup single file
- `backup_config "path" "name"` - Backup config if not symlink
- `backup_configs()` - Backup all common configs

**Restore Functions:**
- `list_backups()` - List available backups
- `restore_backup "id"` - Restore specific backup
- `restore_latest_backup()` - Restore most recent backup

**Cleanup Functions:**
- `clean_old_backups [count]` - Keep only N most recent backups (default: 5)
- `delete_backup "id"` - Delete specific backup
- `delete_all_backups()` - Delete all backups

**Info Functions:**
- `show_backup_info "id"` - Show backup details
- `show_backup_stats()` - Show backup statistics

**Example:**
```bash
source libs/backup.sh

# Backup before making changes
backup_configs

# List available backups
list_backups

# Restore if something goes wrong
restore_latest_backup

# Cleanup old backups
clean_old_backups 3  # Keep only 3 most recent
```

### `package.sh`

Package manager abstraction layer for cross-distro compatibility.

**Functions:**
- `pkg_update()` - Update package lists
- `pkg_install "package1" "package2" ...` - Install packages
- `pkg_install_if_missing "package" [command]` - Install if not present
- `pkg_remove "package1" "package2" ...` - Remove packages
- `pkg_search "query"` - Search for packages
- `pkg_info "package"` - Show package information
- `pkg_upgrade()` - Upgrade all packages
- `pkg_add_repo "repo"` - Add repository
- `pkg_clean()` - Clean package cache
- `pkg_install_list "file"` - Install from package list file
- `is_package_installed "package"` - Check if installed
- `list_installed_packages()` - List all installed packages

**Snap/Flatpak:**
- `snap_install "package" [flags]` - Install snap package
- `flatpak_install "package"` - Install flatpak package

**Example:**
```bash
source libs/package.sh

# Update and install packages (works on apt, dnf, brew, etc.)
pkg_update
pkg_install git curl wget neovim

# Install only if missing
pkg_install_if_missing "zsh"

# Check if installed
if is_package_installed "docker"; then
    echo "Docker is installed"
fi

# Clean up
pkg_clean
```

## Usage in Scripts

### Basic Script Template

```bash
#!/usr/bin/env bash
# scripts/my-installer.sh

set -e  # Exit on error

# Get script directory and source libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source all libraries
source "$DOTFILES/libs/init.sh"

# Your script logic
log_header "Installing My Tool"

if is_macos; then
    log_info "Detected macOS"
    pkg_install "my-tool"
elif is_ubuntu; then
    log_info "Detected Ubuntu"
    pkg_update
    pkg_install "my-tool"
fi

link_config "$DOTFILES/config/my-tool/config.yml" "$HOME/.config/my-tool/config.yml"

log_success "Installation complete!"
```

### Advanced Script Template

```bash
#!/usr/bin/env bash
# scripts/advanced-installer.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES/libs/init.sh"

main() {
    print_banner "MY TOOL INSTALLER"

    # Check prerequisites
    check_internet || exit 1

    # Backup existing configs
    log_header "Backing up existing configs"
    backup_config "$HOME/.mytoolrc" "mytoolrc"

    # Install based on OS
    log_header "Installing packages"

    case "$OS" in
        macos)
            install_macos
            ;;
        ubuntu|debian)
            install_debian
            ;;
        fedora)
            install_fedora
            ;;
        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    # Link configs
    log_header "Linking configurations"
    link_config "$DOTFILES/config/mytool/.mytoolrc" "$HOME/.mytoolrc"

    log_success "Installation complete!"
}

install_macos() {
    pkg_install "my-tool"
}

install_debian() {
    pkg_update
    pkg_install "my-tool" "my-tool-extra"
}

install_fedora() {
    pkg_install "my-tool"
}

# Run main function
main "$@"
```

## Environment Variables

- `DEBUG=1` - Enable debug logging
- `VERBOSE=1` - Show command output
- `QUIET=1` - Suppress initialization messages
- `DOTFILES` - Override dotfiles directory path
- `BACKUP_DIR` - Override backup directory

**Example:**
```bash
DEBUG=1 ./scripts/my-installer.sh
```

## Testing

You can test the libraries interactively:

```bash
# Start a bash shell with libraries loaded
bash -c "source libs/init.sh && bash"

# Now you can call any function
show_system_info
log_success "This is a test"
ask_yes_no "Continue?"
```
