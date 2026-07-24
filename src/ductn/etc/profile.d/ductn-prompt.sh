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
    # Build the prompt without an inline sed substitution: BSD sed on
    # macOS rejects `sed "s/^/ (/;s/$/)/"` with "unterminated `s' command"
    # because the trailing `/` is missing before `;`. GNU sed tolerates it,
    # but the package must work on both. We compute the branch string in a
    # local variable and concatenate it via printf instead.
    local _branch=""
    if _branch=$(__ductn_prompt_git_branch) && [ -n "$_branch" ]; then
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]'
        PS1+=$(printf '\033[00m\033[01;33m (%s)\033[00m' "$_branch")
        PS1+='\n\[\033[01;36m\]❯\[\033[00m\] '
    else
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n\[\033[01;36m\]❯\[\033[00m\] '
    fi
}

# Wrap the prompt setter in a PROMPT_COMMAND-friendly entry point. Each
# invocation rebuilds PS1 so the (branch) suffix reflects the current
# working directory's git branch instead of the branch at shell start.
__ductn_prompt_command() {
    __ductn_prompt_set
}

# Only override when PS1 is currently the default bash prompt (or unset),
# so we never clobber a custom user prompt. The matches cover plain bash
# (\s-\v\$ ), Ubuntu/Debian's ${debian_chroot} variant, and an empty PS1.
_default_ps1='\s-\v\$ '
_debian_ps1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
case "$PS1" in
    "$_default_ps1"|"$_debian_ps1")
        # Install the dynamic prompt rebuilder first so subsequent prompts
        # reflect the current branch. Preserve any pre-existing
        # PROMPT_COMMAND (Ubuntu/Debian often sets one for window-title
        # updates); when none is set, install ours alone.
        if [ -n "${PROMPT_COMMAND:-}" ]; then
            case "$PROMPT_COMMAND" in
                *__ductn_prompt_command*)
                    ;; # already chained; nothing to do
                *)
                    PROMPT_COMMAND="__ductn_prompt_command; $PROMPT_COMMAND"
                    ;;
            esac
        else
            PROMPT_COMMAND='__ductn_prompt_command'
        fi
        __ductn_prompt_set
        ;;
esac
