#
# ~/.zshrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias al='sl'
alias du='du -ah'
alias grep='grep --color=auto'
alias gradle-bootrun='./gradlew bootRun --args="--spring.profiles.active=dev"'
alias android='emulator -wipe-data -no-snapshot -no-metrics'
alias shutdown='adb kill-server ; shutdown now'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias grep='rg'
alias snvm='source /usr/share/nvm/init-nvm.sh'
alias env='eval "$(direnv hook zsh)"'


# Key Bindings
bindkey -s '^f' '^utmux-sessionizer\n'

# Prompt
autoload -U colors && colors # Load colors
function rainbow_username {
    local colors=(red yellow green blue cyan magenta white)
    local username=$(whoami)
    local colored_username="%b"
    local color_index=1

    for (( i=0; i<${#username}; i++ )); do
        local char="${username:$i:1}"
        colored_username+="%{$fg[${colors[$color_index]}]%}$char%{$reset_color%}"
        ((color_index = (color_index + 1) % ${#colors[@]}))
    done

    echo $colored_username
}
PS1="%B%{$fg[red]%}[$(rainbow_username)%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1~%B%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd # Automatically cd into typed directory.
stty stop undef # Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
setopt inc_append_history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Include hidden files.

# Path
export PATH=$PATH:/opt/google/chrome
export PATH=$PATH:/home/$USER/.config/bin
export PATH=$PATH:/home/$USER/.cargo/bin

# Other environment variables
export XDG_CONFIG_HOME="$HOME/.config"
export CHROME_EXECUTABLE="$(which google-chrome-stable)"
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"
export EDITOR="nvim"
export ANDROID_AVD_HOME="/home/$USER/.config/.android/avd"
export JAVA_HOME=/usr/lib/jvm/default
export __GL_SYNC_DISPLAY_DEVICE=DP-1
export LIBVA_DRIVER_NAME=nvidia
export XDG_SESSION_TYPE=wayland
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1

# GPG
export GPG_TTY=$(tty)

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete
