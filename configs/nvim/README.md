# Neovim Configuration

LazyVim-based Neovim configuration with Rose Pine colorscheme.

## Files

```
init.lua              # Entry point
lazy-lock.json        # Plugin versions lock file
lazyvim.json          # LazyVim configuration
stylua.toml          # Lua code formatter config

lua/
├── config/
│   ├── autocmds.lua  # Automatic commands
│   ├── keymaps.lua   # Key mappings
│   ├── options.lua   # Vim options
│   └── lazy.lua      # Lazy.nvim plugin manager setup
└── plugins/
    ├── colorscheme.lua  # Rose Pine theme config
    └── neo-tree.lua     # File explorer config
```

## Installation

Symlink to: `~/.config/nvim/`

## Features

### LazyVim Distribution
- Pre-configured Neovim setup
- Plugin management via lazy.nvim
- Sensible defaults
- LSP support built-in

### Colorscheme
- Rose Pine theme (main variant)
- Consistent with Kitty terminal theme

### Plugins
- Neo-tree - File explorer
- Treesitter - Syntax highlighting
- LSP - Language servers
- Telescope - Fuzzy finder
- And many more via LazyVim

## Dependencies

### Required
- Neovim >= 0.9.0
- Git
- A Nerd Font (for icons)

### Recommended
- `ripgrep` - For Telescope live grep
- `fd` - For Telescope file finder
- `lazygit` - Git TUI integration
- Node.js - For LSP servers
- Tree-sitter CLI - For better syntax highlighting

## Quick Start

### First Launch
On first launch, lazy.nvim will automatically:
1. Install itself
2. Install all plugins
3. Compile treesitter parsers

This may take a few minutes.

### Key Bindings (Leader = Space)

**File Navigation:**
- `<leader>e` - Toggle file explorer
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers

**LSP:**
- `gd` - Go to definition
- `gr` - Show references
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol

**Editing:**
- `gcc` - Toggle comment line
- `gc` - Toggle comment (motion)
- `<leader>/` - Search in current buffer

### Commands

- `:Lazy` - Plugin manager UI
- `:Mason` - LSP server installer
- `:checkhealth` - Check Neovim health

## Customization

### Adding Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  "username/plugin-name",
  config = function()
    -- Plugin configuration
  end,
}
```

### Changing Keymaps

Edit `lua/config/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>x", ":command<CR>", { desc = "Description" })
```

### Changing Options

Edit `lua/config/options.lua`:

```lua
vim.opt.relativenumber = true
vim.opt.wrap = false
```

## Troubleshooting

### Plugins not loading?
```vim
:Lazy sync
```

### LSP not working?
```vim
:Mason
```
Install language servers for your languages.

### Syntax highlighting broken?
```vim
:TSUpdate
```

### Clear cache and reinstall
```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
nvim
```

## Resources

- [LazyVim Documentation](https://lazyvim.org)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [Rose Pine Theme](https://rosepinetheme.com)
