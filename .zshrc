# ZSH configuration:
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX=true

plugins=(git docker pyenv dnf common-aliases last-working-dir)

load-custom-env-presets() {
    # Load custom environment variables from the following files:
    #   * `.aliases`: Aliases for common commands.
    #   * `.exports`: Environment variables that should be exported.
    #   * `.functions`: Custom functions.
    for file in ~/.{exports,aliases,functions,extra}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file";
    done;
    unset file;
}

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Set `pyenv` configuration:
if [ -d $HOME/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# Load default configuration:
load-custom-env-presets
source $ZSH/oh-my-zsh.sh
