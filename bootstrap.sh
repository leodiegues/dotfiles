#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

OS_FLAVOR=$1

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "* Checking for updates...[1/3]"
git pull origin main

echo "* Running $OS_FLAVOR setup...[2/3]"
source flavors/$OS_FLAVOR.sh;

run_bootstrap () {
	rsync --exclude ".git/" \
		--exclude "media/" \
        --exclude "flavors/" \
        --exclude ".editorconfig" \
		--exclude ".gitignore" \
        --exclude ".extra.template" \
		--exclude "bootstrap.sh" \
		--exclude "fedora.sh" \
		--exclude "README.md" \
		-avh --no-perms . ~
	zsh
	source ~/.zshrc
}

echo "* Running bootstrap...[3/3]"
if [ "$2" == "--force" -o "$2" == "-f" ]; then
	run_bootstrap
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/N)" -n 1
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		run_bootstrap
	fi
fi
unset run_bootstrap
