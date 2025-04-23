#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias kali='kali.sh'
alias charge-limit='toggle_battery_limit.sh limit'
alias charge-full='toggle_battery_limit.sh full'

# Load wal colors
[ -f "$HOME/.cache/wal/colors.sh" ] && source "$HOME/.cache/wal/colors.sh"

wal-up() {
    local wallpaper="$HOME/Pictures/wallpapers/$1"
    [[ -f "$wallpaper" ]] && command wal -i "$wallpaper" && update_theme.sh
}
