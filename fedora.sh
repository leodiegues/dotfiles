#!/usr/bin/env bash

# This script is run by the Fedora installer and is used to set up the
# development environment.

install-core-packages () {
    # Install the core packages required to build and run the project.
    sudo dnf -y update
    sudo dnf -y install curl zsh util-linux-user terminator 'dnf-command(config-manager)'
    sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf -y install gnome-tweak-tool dnf-plugins-core snapd discord

    if [[ ! -f /snap ]]; then
        echo "* Creating symbolic link for snap..."
        sudo ln -s /var/lib/snapd/snap /snap # configure snapd.
    fi
}

install-oh-my-zsh () {
    if [[ ! -d $HOME/.oh-my-zsh ]]; then
        echo "\n* Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh is already installed."
    fi
}

install-vscode () {
    # Install Visual Studio Code
    if [[ ! -f /usr/bin/code ]]; then
        echo "\n* Installing VSCode..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf -y install code
    else
        echo "Visual Studio Code is already installed."
    fi
}

install-docker () {
    # Install Docker-CE
    if [[ ! -f /usr/bin/docker ]]; then
        echo "\n* Installing Docker..."
        sudo dnf -y install docker
        sudo systemctl enable docker
        sudo systemctl start docker
        sudo usermod -aG docker $USER
    else
        echo "Docker is already installed."
    fi
}

install-pyenv () {
    # Install latest version of Pyenv
    if [[ ! -d $HOME/.pyenv ]]; then
        echo "\n* Installing Pyenv..."
        sudo dnf -y install readline-devel.x86_64 libsq3-devel.x86_64
        curl https://pyenv.run | bash
    else
        echo "Pyenv is already installed."
    fi
}

install-r () {
    # Install R + useful packages from tidyverse
    if [[ ! -f /usr/bin/R ]]; then
        echo "\n* Installing R..."
        sudo dnf -y install R libcurl-devel openssl-devel libxml2-devel 'dnf-command(copr)'
        sudo dnf -y install R-dplyr R-dbplyr R-purrr R-tidyr R-readr R-ggplot2 R-httr R-rvest
        sudo dnf copr enable -y iucar/cran
        sudo dnf -y install R-CoprManager # for additional packages
    else
        echo "R is already installed."
    fi
}

install-snx () {
    # Install and setup SNX VPN client
    #   * Referenced from: https://gist.github.com/ikurni/b88b8f32eacd2e39c11cb52b6f0b5ba2

    if [[ ! -f /usr/bin/snx ]]; then
        ## Install few required packages to run SNX
        echo "\n* Installing SNX VPN client..."
        sudo dnf install -y java-1.8.0-openjdk.x86_64 libstdc++.i686 libX11.i686 libpamtest.i686 libnsl.i686
        wget http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.i686.rpm
        sudo dnf -y install compat-libstdc++-33-3.2.3-72.el7.i686.rpm
        rm -f compat-libstdc++-33-3.2.3-72.el7.i686.rpm

        ## Install snx_linux.sh
        chmod +x ./bin/snx_install_linux30.sh
        sudo ./bin/snx_install_linux30.sh
    else
        echo "SNX is already installed."
    fi
}

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

## Installing core packages
install-core-packages

## Setting ZSH as the default shell:
chsh -s $(which zsh)

## Installing other essential packages
install-oh-my-zsh
install-vscode
install-pyenv
install-r
install-snx

## Intalling snap packages:
sudo snap install cider --edge
sudo snap install insomnia
sudo snap install dbeaver-ce

## Override GNOME settings:
fix-us-intl-keyboard-cedilla
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/terminator
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.mutter workspaces-only-on-primary false

