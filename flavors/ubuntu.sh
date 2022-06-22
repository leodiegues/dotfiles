#!/usr/bin/env bash

# This script is run by the Fedora installer and is used to set up the
# development environment.

install-core-packages () {
    # Install the core packages required to build and run the project.
    echo "\n* Installing core packages..."

    sudo apt update -y
    sudo apt install -y curl \
        zsh \
        terminator \
        wget \
        gpg \
        apt-transport-https \
        gnome-tweaks \
        snapd \
        ca-certificates \
        gnupg \
        gdebi \
        software-properties-common \
        dirmngr \
        lsb-release \
        libssl-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        libcurl4-openssl-dev \
        libreadline-dev \
        libreadline8 \
        python-tk \
        tk-dev

    if [[ ! -d /snap ]]; then
        echo "  - Creating symbolic link for snap..."
        sudo ln -s /var/lib/snapd/snap /snap # configure snapd.
    fi

    # Setting zsh as the default shell
    echo "  - Setting Zsh as the default shell..."
    chsh -s $(which zsh)
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
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        sudo apt install code
    else
        echo "Visual Studio Code is already installed."
    fi
}

install-docker () {
    # Install Docker-CLI and Docker Compose
    if [[ ! -f /usr/bin/docker ]]; then
        echo "\n* Installing Docker..."
        sudo apt remove docker docker-engine docker.io containerd runc
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        sudo groupadd docker
        sudo usermod -aG docker $USER
        sudo systemctl enable docker.service
        sudo systemctl enable containerd.service
    else
        echo "Docker is already installed."
    fi
}

install-pyenv () {
    # Install latest version of Pyenv
    if [[ ! -d $HOME/.pyenv ]]; then
        echo "\n* Installing Pyenv..."
        curl https://pyenv.run | bash
    else
        echo "Pyenv is already installed."
    fi
}

install-r () {
    # Install R + useful packages from tidyverse
    if [[ ! -f /usr/bin/R ]]; then
        echo "\n* Installing R..."
        wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
        sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" -y
        sudo add-apt-repository ppa:c2d4u.team/c2d4u4.0+ -y
        sudo apt install -y --no-install-recommends r-base r-base-dev r-cran-tidyverse r-cran-sf
    else
        echo "R is already installed."
    fi
}

install-snx () {
    # Install and setup SNX VPN client
    #   * Referenced from: https://gist.github.com/ikurni/b88b8f32eacd2e39c11cb52b6f0b5ba2

    if [[ ! -f /usr/bin/snx ]]; then
        ## Install required dependencies
        echo "\n* Installing SNX VPN client..."
        sudo dpkg --add-architecture i386 -y
        sudo apt update
        sudo apt install -y libx11-6:i386 libpam0g:i386 libstdc++5:i386 

        ## Install snx_linux.sh
        chmod +x ./utils/snx_install_linux30.sh
        sudo ./utils/snx_install_linux30.sh
    else
        echo "SNX is already installed."
    fi
}

install-discord () {
    # Install Discord client
    if [[ ! -f /usr/bin/discord ]]; then
        wget -O $HOME/Downloads/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
        sudo dpkg -i $HOME/Downloads/discord.deb
        sudo apt install -y -f
    else
        echo "Discord is already installed."
    fi
}

fix-us-intl-keyboard-cedilla () {
    # Fix cedilla problem in US International keyboard layout
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
install-oh-my-zsh
install-vscode
install-pyenv
install-r
install-snx
install-discord

## Intalling snap packages:
sudo snap install cider --edge
sudo snap install insomnia
sudo snap install dbeaver-ce

## Override GNOME settings:
fix-us-intl-keyboard-cedilla
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/terminator 50
gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.mutter workspaces-only-on-primary false
gsettings set org.gnome.shell.app-switcher current-workspace-only true
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
