# Dotfiles Configurations

This directory contains all configuration files (dotfiles) organized by application.

## Directory Structure

```
configs/
├── zsh/          # Zsh shell configuration
├── tmux/         # Tmux terminal multiplexer
├── neovim/       # Neovim editor (LazyVim)
├── kitty/        # Kitty terminal emulator
└── direnv/       # Direnv environment manager
```

## Configurations

### Zsh (`configs/zsh/`)

Shell configuration files for Zsh with Oh-My-Zsh.

**Files:**
- `.zshrc` - Main Zsh configuration
- `.aliases` - Shell aliases
- `.exports` - Environment variables
- `.functions` - Custom shell functions

**Installation locations:**
```
~/.zshrc
~/.aliases
~/.exports
~/.functions
```

**Dependencies:**
- Zsh shell
- Oh-My-Zsh framework

**Features:**
- Oh-My-Zsh plugins: git, docker, pyenv
- Custom aliases for Docker, system commands, navigation
- Environment setup for nvim, pyenv, pnpm
- Custom helper functions

---

### Tmux (`configs/tmux/`)

Terminal multiplexer configuration.

**Files:**
- `tmux.conf` - Main tmux configuration

**Installation location:**
```
~/.config/tmux/tmux.conf
```

**Features:**
- Prefix changed from `C-b` to `C-a`
- Vi-mode bindings for copy mode
- Vim-like pane navigation (`hjkl`)
- Mouse support enabled
- 256-color terminal support
- Custom status bar styling
- Clipboard integration with xclip

**Key bindings:**
- `C-a |` - Split pane vertically
- `C-a -` - Split pane horizontally
- `C-a h/j/k/l` - Navigate panes
- `C-a [` - Enter copy mode

---

### Neovim (`configs/neovim/`)

Neovim editor configuration using LazyVim.

**Files:**
- `init.lua` - Entry point
- `lazy-lock.json` - Plugin lock file
- `lazyvim.json` - LazyVim configuration
- `stylua.toml` - Lua formatter config
- `lua/config/` - Core configuration
  - `autocmds.lua` - Auto commands
  - `keymaps.lua` - Key mappings
  - `options.lua` - Vim options
  - `lazy.lua` - Lazy plugin manager setup
- `lua/plugins/` - Plugin configurations
  - `colorscheme.lua` - Rose Pine theme
  - `neo-tree.lua` - File explorer

**Installation location:**
```
~/.config/nvim/
```

**Dependencies:**
- Neovim (latest stable or nightly)
- Git
- A Nerd Font (for icons)
- ripgrep (for telescope)
- fd (for telescope)
- Node.js (for LSP servers)

**Features:**
- LazyVim distribution
- Rose Pine colorscheme
- Neo-tree file explorer
- LSP support
- Treesitter syntax highlighting
- Telescope fuzzy finder

---

### Kitty (`configs/kitty/`)

Modern terminal emulator configuration.

**Files:**
- `kitty.conf` - Main configuration
- `themes/rose-pine.conf` - Rose Pine color theme

**Installation location:**
```
~/.config/kitty/
```

**Features:**
- Font: Comic Code Ligatures (size 10.0)
- Theme: Rose Pine
- GPU-accelerated rendering
- Ligature support
- Customizable tabs and splits

**Dependencies:**
- Kitty terminal emulator
- Comic Code font (installed via fonts script)

---

### Direnv (`configs/direnv/`)

Directory-based environment variable manager.

**Files:**
- `direnvrc` - Main direnv configuration
- `direnv.toml` - TOML-based settings

**Installation location:**
```
~/.config/direnv/
```

**Dependencies:**
- Direnv

**Features:**
- Automatic environment loading per directory
- Support for `.envrc` files
- Shell integration (zsh, bash)

---

## How These Configs Are Used

### During Installation

Installation scripts in `scripts/` use the `link_config()` function from `libs/utils.sh` to create symlinks:

```bash
# Example from scripts/shell/zsh.sh
source "$DOTFILES/libs/init.sh"

link_config "$DOTFILES/configs/zsh/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES/configs/zsh/.aliases" "$HOME/.aliases"
link_config "$DOTFILES/configs/zsh/.exports" "$HOME/.exports"
link_config "$DOTFILES/configs/zsh/.functions" "$HOME/.functions"
```

### Symlink Strategy

All configs are **symlinked** (not copied), which means:

✅ **Always in sync** - Edit `~/.zshrc` and changes appear in `configs/zsh/.zshrc` instantly
✅ **Git tracked** - Changes are immediately visible in git
✅ **Easy updates** - `git pull` updates your configs automatically
✅ **No duplication** - One source of truth

### Backup Before Linking

The installation scripts automatically backup any existing configs before creating symlinks:

```
~/.zshrc → ~/.zshrc.backup.1733508123
```

Backups are stored in `~/.dotfiles-backups/` with timestamps.

---

## Managing Your Configs

### Making Changes

Edit configs anywhere (they're symlinked):

```bash
# Edit in home directory
nvim ~/.zshrc

# Or edit in dotfiles repo
nvim ~/.dotfiles/configs/zsh/.zshrc

# Both are the same file!
```

### Committing Changes

```bash
# Check what changed
cd ~/.dotfiles
git status

# Commit changes
git add configs/
git commit -m "Update zsh aliases"
git push
```

### Using Aliases (from configs/zsh/.zshrc)

```bash
# Dotfiles shortcuts
dfs          # cd to dotfiles and show git status
dfc          # Add all and commit
dfp          # Pull latest changes
dfP          # Push changes
dfe          # Edit dotfiles in $EDITOR
```

---

## Adding New Configs

### Step 1: Add config files to `configs/`

```bash
mkdir -p configs/my-app
cp ~/.config/my-app/config.yml configs/my-app/
```

### Step 2: Create installation script

```bash
# scripts/tools/my-app.sh
#!/usr/bin/env bash

source "$DOTFILES/libs/init.sh"

log_header "Installing My App"

pkg_install my-app

link_config "$DOTFILES/configs/my-app/config.yml" \
            "$HOME/.config/my-app/config.yml"

log_success "My App configured!"
```

### Step 3: Make it executable

```bash
chmod +x scripts/tools/my-app.sh
```

### Step 4: Add to main installer

Update `install.sh` to include your new script.

---

## OS-Specific Notes

### macOS
- Most configs work as-is on macOS
- GNOME settings don't apply (Linux only)
- Some package names differ (handled by `libs/package.sh`)

### Ubuntu/Debian
- All configs supported
- APT package manager
- GNOME desktop settings available

### Fedora
- All configs supported
- DNF package manager
- GNOME desktop settings available

### Common Locations

**Linux:**
```
~/.config/          # XDG config directory
~/.local/share/     # XDG data directory
~/                  # Home directory (shell dotfiles)
```

**macOS:**
```
~/.config/          # XDG config directory (honored by most tools)
~/Library/          # macOS-specific configs
~/                  # Home directory (shell dotfiles)
```

---

## Best Practices

### ✅ Do

- Edit configs through symlinks (anywhere)
- Commit changes regularly
- Test configs on a fresh machine occasionally
- Document any manual setup required
- Use environment variables for machine-specific paths
- Keep secrets out of dotfiles (use `.secrets` file, gitignored)

### ❌ Don't

- Copy configs instead of symlinking
- Hardcode absolute paths (use `$HOME` or `~`)
- Commit sensitive data (API keys, passwords)
- Edit configs in both locations (they're symlinked!)
- Delete the dotfiles repo without unlinking first

---

## Troubleshooting

### Symlink not working?

Check if symlink exists:
```bash
ls -la ~/.zshrc
# Should show: ~/.zshrc -> /Users/you/.dotfiles/configs/zsh/.zshrc
```

### Config not taking effect?

Reload the config:
```bash
# Zsh
source ~/.zshrc

# Tmux
tmux source-file ~/.config/tmux/tmux.conf

# Neovim
:source ~/.config/nvim/init.lua
```

### Want to restore original configs?

```bash
# List backups
cd ~/.dotfiles
source libs/init.sh
list_backups

# Restore latest
restore_latest_backup
```

---

## File Permissions

All config files should be readable by user:
```bash
chmod 644 configs/**/*
```

Sensitive files (if any) should be restricted:
```bash
chmod 600 ~/.secrets
```
