#!/usr/bin/env bash
# libs/backup.sh - Backup and restore functions for configuration files

BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backups}"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ============================================================================
# Backup Functions
# ============================================================================

create_backup_dir() {
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "📁 Created backup directory: $BACKUP_DIR"
  fi
}

backup_file() {
  local file="$1"
  local backup_name="${2:-$(basename "$file")}"
  local backup_path="$BACKUP_DIR/${BACKUP_TIMESTAMP}_${backup_name}"

  if [ ! -e "$file" ]; then
    echo "⚠️  File does not exist: $file"
    return 1
  fi

  create_backup_dir

  if [ -L "$file" ]; then
    echo "⚠️  Skipping symlink: $file"
    return 0
  fi

  cp -r "$file" "$backup_path"
  echo "💾 Backed up: $file → $backup_path"
  return 0
}

backup_config() {
  local config_path="$1"
  local config_name="$2"

  if [ -e "$config_path" ] && [ ! -L "$config_path" ]; then
    backup_file "$config_path" "$config_name"
    return $?
  fi

  return 0
}

backup_configs() {
  echo "🔄 Creating backup of existing configurations..."
  create_backup_dir

  local backup_subdir="$BACKUP_DIR/$BACKUP_TIMESTAMP"
  mkdir -p "$backup_subdir"

  local files_backed_up=0

  # Common config locations to back up
  local configs=(
    "$HOME/.zshrc:zshrc"
    "$HOME/.bashrc:bashrc"
    "$HOME/.aliases:aliases"
    "$HOME/.exports:exports"
    "$HOME/.functions:functions"
    "$HOME/.tmux.conf:tmux.conf"
    "$HOME/.config/nvim:nvim"
    "$HOME/.config/kitty:kitty"
    "$HOME/.config/direnv:direnv"
  )

  for config in "${configs[@]}"; do
    IFS=':' read -r path name <<<"$config"

    if [ -e "$path" ] && [ ! -L "$path" ]; then
      cp -r "$path" "$backup_subdir/$name"
      echo "💾 Backed up: $path"
      ((files_backed_up++))
    fi
  done

  if [ $files_backed_up -eq 0 ]; then
    rmdir "$backup_subdir" 2>/dev/null
    echo "ℹ️  No existing configs to backup"
  else
    echo "✅ Backed up $files_backed_up config(s) to: $backup_subdir"
  fi

  return 0
}

# ============================================================================
# Restore Functions
# ============================================================================

list_backups() {
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "ℹ️  No backups found"
    return 1
  fi

  echo "Available backups:"
  ls -1t "$BACKUP_DIR" | grep -E '^[0-9]{8}_[0-9]{6}' | while read -r backup; do
    local size=$(du -sh "$BACKUP_DIR/$backup" 2>/dev/null | cut -f1)
    echo "  • $backup ($size)"
  done
}

restore_backup() {
  local backup_id="$1"

  if [ -z "$backup_id" ]; then
    echo "❌ Error: Backup ID required"
    list_backups
    return 1
  fi

  local backup_path="$BACKUP_DIR/$backup_id"

  if [ ! -d "$backup_path" ]; then
    echo "❌ Error: Backup not found: $backup_id"
    return 1
  fi

  echo "🔄 Restoring backup from: $backup_id"

  # Restore files
  for file in "$backup_path"/*; do
    local basename=$(basename "$file")
    local target

    case "$basename" in
    zshrc) target="$HOME/.zshrc" ;;
    bashrc) target="$HOME/.bashrc" ;;
    aliases) target="$HOME/.aliases" ;;
    exports) target="$HOME/.exports" ;;
    functions) target="$HOME/.functions" ;;
    tmux.conf) target="$HOME/.tmux.conf" ;;
    nvim) target="$HOME/.config/nvim" ;;
    kitty) target="$HOME/.config/kitty" ;;
    direnv) target="$HOME/.config/direnv" ;;
    *) target="$HOME/$basename" ;;
    esac

    # Remove existing file/symlink
    if [ -e "$target" ]; then
      rm -rf "$target"
    fi

    # Restore from backup
    cp -r "$file" "$target"
    echo "📥 Restored: $target"
  done

  echo "✅ Backup restored successfully"
  return 0
}

restore_latest_backup() {
  local latest=$(ls -1t "$BACKUP_DIR" | grep -E '^[0-9]{8}_[0-9]{6}' | head -n 1)

  if [ -z "$latest" ]; then
    echo "❌ No backups found"
    return 1
  fi

  echo "🔄 Restoring latest backup: $latest"
  restore_backup "$latest"
}

# ============================================================================
# Cleanup Functions
# ============================================================================

clean_old_backups() {
  local keep_count="${1:-5}"

  if [ ! -d "$BACKUP_DIR" ]; then
    return 0
  fi

  echo "🧹 Cleaning old backups (keeping last $keep_count)..."

  local backups=($(ls -1t "$BACKUP_DIR" | grep -E '^[0-9]{8}_[0-9]{6}'))
  local backup_count=${#backups[@]}

  if [ "$backup_count" -le "$keep_count" ]; then
    echo "ℹ️  Only $backup_count backup(s) found, nothing to clean"
    return 0
  fi

  local remove_count=$((backup_count - keep_count))

  for ((i = keep_count; i < backup_count; i++)); do
    local backup="${backups[$i]}"
    rm -rf "$BACKUP_DIR/$backup"
    echo "🗑️  Removed old backup: $backup"
  done

  echo "✅ Removed $remove_count old backup(s)"
}

delete_backup() {
  local backup_id="$1"

  if [ -z "$backup_id" ]; then
    echo "❌ Error: Backup ID required"
    list_backups
    return 1
  fi

  local backup_path="$BACKUP_DIR/$backup_id"

  if [ ! -d "$backup_path" ]; then
    echo "❌ Error: Backup not found: $backup_id"
    return 1
  fi

  rm -rf "$backup_path"
  echo "🗑️  Deleted backup: $backup_id"
}

delete_all_backups() {
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "ℹ️  No backups to delete"
    return 0
  fi

  echo "⚠️  This will delete ALL backups!"
  read -r -p "Are you sure? [y/N] " response

  case "$response" in
  [yY][eE][sS] | [yY])
    rm -rf "$BACKUP_DIR"
    echo "🗑️  All backups deleted"
    ;;
  *)
    echo "❌ Cancelled"
    return 1
    ;;
  esac
}

# ============================================================================
# Archive Functions
# ============================================================================

archive_backup() {
  local backup_id="$1"

  if [ -z "$backup_id" ]; then
    backup_id=$(ls -1t "$BACKUP_DIR" | grep -E '^[0-9]{8}_[0-9]{6}' | head -n 1)
  fi

  if [ -z "$backup_id" ]; then
    echo "❌ No backup found to archive"
    return 1
  fi

  local backup_path="$BACKUP_DIR/$backup_id"
  local archive_path="$BACKUP_DIR/${backup_id}.tar.gz"

  if [ ! -d "$backup_path" ]; then
    echo "❌ Error: Backup not found: $backup_id"
    return 1
  fi

  echo "📦 Creating archive: ${backup_id}.tar.gz"
  tar -czf "$archive_path" -C "$BACKUP_DIR" "$backup_id"
  rm -rf "$backup_path"

  echo "✅ Backup archived: $archive_path"
}

extract_backup_archive() {
  local archive="$1"

  if [ ! -f "$archive" ]; then
    echo "❌ Error: Archive not found: $archive"
    return 1
  fi

  echo "📦 Extracting archive: $(basename "$archive")"
  tar -xzf "$archive" -C "$BACKUP_DIR"

  echo "✅ Archive extracted"
}

# ============================================================================
# Info Functions
# ============================================================================

show_backup_info() {
  local backup_id="$1"

  if [ -z "$backup_id" ]; then
    echo "❌ Error: Backup ID required"
    return 1
  fi

  local backup_path="$BACKUP_DIR/$backup_id"

  if [ ! -d "$backup_path" ]; then
    echo "❌ Error: Backup not found: $backup_id"
    return 1
  fi

  echo "Backup Information:"
  echo "  ID:       $backup_id"
  echo "  Path:     $backup_path"
  echo "  Size:     $(du -sh "$backup_path" | cut -f1)"
  echo "  Created:  $(stat -f %Sm "$backup_path" 2>/dev/null || stat -c %y "$backup_path" 2>/dev/null)"
  echo ""
  echo "Contents:"
  ls -lh "$backup_path" | tail -n +2 | awk '{print "  " $9 " (" $5 ")"}'
}

show_backup_stats() {
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "ℹ️  No backups found"
    return 0
  fi

  local backup_count=$(ls -1 "$BACKUP_DIR" | grep -E '^[0-9]{8}_[0-9]{6}' | wc -l)
  local total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)

  echo "Backup Statistics:"
  echo "  Location:       $BACKUP_DIR"
  echo "  Total backups:  $backup_count"
  echo "  Total size:     $total_size"
}
