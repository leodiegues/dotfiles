#!/usr/bin/env bash

# This script is run by the Fedora installer and is used to set up the
# development environment.

# Package installation ----------------------------------------------------------

install-core-packages() {
    # Install the core packages required to build and run the project.
    sudo dnf -y update
    sudo dnf -y install zsh util-linux-user terminator 'dnf-command(config-manager)'
    sudo dnf -y install gnome-tweak-tool dnf-plugins-core
}

install-vscode() {
    # Install Visual Studio Code
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf -y install code
}

install-docker() {
    # Install Docker-CE
    sudo dnf -y install docker
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
}

install-r () {
    # Install R + useful packages from tidyverse
    sudo dnf -y install R libcurl-devel openssl-devel libxml2-devel 'dnf-command(copr)'
    sudo dnf -y install R-dplyr R-dbplyr R-purrr R-tidyr R-readr R-ggplot2 R-httr R-rvest
    sudo dnf copr enable -y iucar/cran
    sudo dnf -y install R-CoprManager # for additional packages
}

install-snx () {
    # Install SNX VPN client
    #   * Referenced from: https://gist.github.com/ikurni/b88b8f32eacd2e39c11cb52b6f0b5ba2

    ## Install few required packages to run SNX
    sudo dnf install -y java-1.8.0-openjdk.x86_64 libstdc++.i686 libX11.i686 libpamtest.i686 libnsl.i686
    wget http://mirror.centos.org/centos/7/os/x86_64/Packages/compat-libstdc++-33-3.2.3-72.el7.i686.rpm
    sudo dnf -y install compat-libstdc++-33-3.2.3-72.el7.i686.rpm
    rm -f compat-libstdc++-33-3.2.3-72.el7.i686.rpm

    ## Install snx_linux.sh
    wget https://vpnportal.aktifbank.com.tr/SNX/INSTALL/snx_install.sh
    chmod +x snx_install.sh
    sudo ./snx_install.sh
    rm -f snx_install.sh
}

install-core-packages

## Installing Visual Studio Code:
if [[ ! -f /usr/bin/code ]]; then
    install-vscode
fi

## Installing Docker:
if [[ ! -f /usr/bin/docker ]]; then
    install-docker
fi

## Installing pyenv:
if [[ ! -d $HOME/.pyenv ]]; then
    curl https://pyenv.run | bash
fi

## Installing R:
if [[ ! -f /usr/bin/R ]]; then
    install-r
fi

## Installing SNX and adding a ~/.snxrc file:
if [[ ! -f /usr/bin/snx ]]; then
    install-snx
fi

# Terminal configuration --------------------------------------------------------

## Setting terminator as the default terminal:
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/terminator

## Setting ZSH as the default shell:
chsh -s $(which zsh)


