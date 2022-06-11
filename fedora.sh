#!/usr/bin/env zsh

# This script is run by the Fedora installer and is used to set up the
# development environment.

# Package installation and configuration ----------------------------------------

## General
sudo dnf -y update
sudo dnf -y install zsh util-linux-user terminator 'dnf-command(config-manager)'
sudo dnf -y install gnome-tweak-tool dnf-plugins-core

## Installing VSCode:
# sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
# sudo dnf -y install code

## Installing Docker:
sudo dnf -y install docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

## Installing pyenv:
curl https://pyenv.run | bash

# Setting ZSH as the default shell:
chsh -s $(which zsh)

# Generating SSH Key:
ssh-keygen -t rsa -C $GIT_AUTHOR_EMAIL
ssh-add ~/.ssh/id_rsa

