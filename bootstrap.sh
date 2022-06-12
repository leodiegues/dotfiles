#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "* Checking for updates...[1/3]"
git pull origin main

echo "* Running Fedora setup...[2/3]"
source fedora.sh;

run_bootstrap () {
	rsync --exclude ".gitignore" \
		--exclude ".git/" \
		--exclude "bootstrap.sh" \
		--exclude "fedora.sh" \
		--exclude "README.md" \
		-avh --no-perms . ~
	zsh
	source ~/.zshrc
}

echo "* Running bootstrap...[3/3]"
if [ "$1" == "--force" -o "$1" == "-f" ]; then
	run_bootstrap
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/N)" -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		run_bootstrap
	fi
fi
unset run_bootstrap
