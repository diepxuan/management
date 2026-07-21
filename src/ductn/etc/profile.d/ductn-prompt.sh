#!/bin/sh
# /etc/profile.d/ductn-prompt.sh — DiepXuan / ductn package
#
# Colored interactive bash prompt with current git branch.
# Installed as a Debian conffile; safe to edit locally (changes survive
# `apt upgrade` until you mark them as merged).
#
# Disable per-user:
#   touch ~/.config/ductn/no-prompt
# or:
#   export DUCTN_PROMPT_DISABLE=1
#
# This file is a no-op for non-bash shells, login shells without an
# interactive prompt (PS1 unset), and shells that already run another
# prompt manager (starship, oh-my-bash, p10k, …).

# Bail when explicitly disabled or already loaded.
[ -n "$DUCTN_PROMPT_DISABLE" ] && return 0
[ -n "$DUCTN_PROMPT_LOADED" ] && return 0

# Bail when a user-level opt-out file exists.
_user_optout="${XDG_CONFIG_HOME:-$HOME/.config}/ductn/no-prompt"
if [ -f "$_user_optout" ]; then
    return 0
fi

# Bail when another prompt manager is in charge.
case "$PS1" in
    *starship*|*oh-my-bash*|*oh_my_bash*|*p10k*|*powerlevel*)
        return 0 ;;
esac

# Only act inside bash interactive shells.
if [ -z "$BASH_VERSION" ]; then
    return 0
fi
case "$-" in
    *i*) ;;
    *) return 0 ;;
esac

export DUCTN_PROMPT_LOADED=1
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

__ductn_prompt_git_branch() {
    git branch 2>/dev/null | sed -n 's/^\* //p'
}

__ductn_prompt_set() {
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(__ductn_prompt_git_branch | sed "s/^/ (/;s/$/)")
\[\033[01;36m\]❯\[\033[00m\] '
}

# Only override when PS1 is currently the default bash prompt (or unset),
# so we never clobber a custom user prompt. The matches cover plain bash
# (\s-\v\$ ), Ubuntu/Debian's ${debian_chroot} variant, and an empty PS1.
_default_ps1='\s-\v\$ '
_debian_ps1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
case "$PS1" in
    "$_default_ps1"|"$_debian_ps1")
        __ductn_prompt_set ;;
esac