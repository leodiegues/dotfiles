# ZSH configuration:
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX=true

plugins=(git docker pyenv)

# Load default configuration:
source $ZSH/oh-my-zsh.sh

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Load auxiliary dotfiles:
source $HOME/.functions
echo "🔧 Functions loaded!"

source $HOME/.aliases
echo "🔧 Aliases loaded!"

source $HOME/.exports
echo "🔧 Exports loaded!"

if [ -f $HOME/.secrets ]; then
    source $HOME/.secrets
    echo "🔒 Secrets loaded!"
fi

# Load `pyenv` if available:
if [ -d $HOME/.pyenv ]; then
    eval "$(pyenv init --path)"
fi

# Load direnv if available:
if [ -d /usr/bin/direnv ]; then
    eval "$(direnv hook zsh)"
fi

