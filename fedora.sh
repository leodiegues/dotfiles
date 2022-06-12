#!/usr/bin/env bash

# This script is run by the Fedora installer and is used to set up the
# development environment.

# Package installation ----------------------------------------------------------

## General
sudo dnf -y update
sudo dnf -y install zsh util-linux-user terminator 'dnf-command(config-manager)'
sudo dnf -y install gnome-tweak-tool dnf-plugins-core

## Installing VSCode:
if [[ ! -f /usr/bin/code ]]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    sudo dnf -y install code
fi

## Installing Docker:
if [[ ! -f /usr/bin/docker ]]; then
  sudo dnf -y install docker
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker $USER
fi

## Installing pyenv:
if [[ ! -d $HOME/.pyenv ]]; then
    curl https://pyenv.run | bash
fi

## Installing R:
if [[ ! -f /usr/bin/R ]]; then
    sudo dnf -y install R libcurl-devel openssl-devel libxml2-devel 'dnf-command(copr)'
    sudo dnf -y install R-dplyr R-dbplyr R-purrr R-tidyr R-readr R-ggplot2 R-httr R-rvest
    sudo dnf copr enable -y iucar/cran
    sudo dnf -y install R-CoprManager # for additional packages
fi

# Terminal configuration --------------------------------------------------------

## Setting terminator as the default terminal:
gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/terminator

## Setting ZSH as the default shell:
chsh -s $(which zsh)


