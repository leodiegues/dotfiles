# Zsh Configuration

Shell configuration for Zsh with Oh-My-Zsh framework.

## Files

- `.zshrc` - Main configuration file
- `.aliases` - Command aliases
- `.exports` - Environment variables
- `.functions` - Custom shell functions

## Installation

Symlinks to:
```
~/.zshrc
~/.aliases
~/.exports
~/.functions
```

## Features

### Oh-My-Zsh Plugins
- `git` - Git aliases and functions
- `docker` - Docker completions and aliases
- `pyenv` - Python version management

### Custom Aliases

**Docker:**
- `dps` - docker ps
- `di` - docker images
- `dex` - docker exec -it
- `dlog` - docker logs -f
- `dstop` - docker stop
- `drm` - docker rm
- `drmi` - docker rmi

**System:**
- `ll` - ls -lah
- `la` - ls -A
- `l` - ls -CF
- `..` - cd ..
- `...` - cd ../..

**Ansible:**
- `ap` - ansible-playbook

### Environment Variables

- `EDITOR` - Set to nvim
- `HISTSIZE` / `HISTFILESIZE` - History settings
- `LANG` / `LC_ALL` - Locale settings
- `PYENV_ROOT` - Python environment root
- `PNPM_HOME` - PNPM package manager

### Custom Functions

Additional shell functions loaded from `.functions`

## Dependencies

- Zsh (`/bin/zsh`)
- Oh-My-Zsh framework
- Optional: pyenv, docker, ansible

## Usage

After installation, restart your shell or:
```bash
source ~/.zshrc
```
