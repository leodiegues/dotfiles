#!/usr/bin/env bash

set -e

tags="$1"

if [ -z $tags ]; then
	tags="all"
fi

if ! [ -x "$(command -v ansible)" ]; then
	sudo apt install ansible
fi

ansible-playbook ~/.dotfiles/playbook.yml --ask-become-pass --tags $tags

if command -v terminal-notifier 1>/dev/null 2>&1; then
	terminal-notifier -title "dotfiles: Bootstrap complete" -message "Successfully set up dev environment."
fi
