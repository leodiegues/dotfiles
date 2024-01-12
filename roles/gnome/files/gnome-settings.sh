#!/usr/bin/bash

# Fixes cedilla in US International keyboard
fix-us-intl-keyboard-cedilla () {
    if [[ ! -f $HOME/.XCompose ]]; then
        echo "\n* Fixing cedilla in US International keyboard..."
        wget -q https://raw.githubusercontent.com/marcopaganini/gnome-cedilla-fix/master/fix-cedilla -O fix-cedilla
        chmod 755 fix-cedilla
        ./fix-cedilla
        rm -f fix-cedilla
    else
        echo "Cedilla fix is already installed."
    fi
}
fix-us-intl-keyboard-cedilla

# Disable animations
gsettings set org.gnome.desktop.interface enable-animations false

# Split workspace into multiple screens
gsettings set org.gnome.mutter workspaces-only-on-primary false

# Alt-tab only on current workspace
gsettings set org.gnome.shell.app-switcher current-workspace-only true
