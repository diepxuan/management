#!/bin/bash
# Installation:
#  Append to ~/.bash_completion
# open new or restart existing shell session

_ductn() {
    local cur script coms opts com
    COMPREPLY=()
    _get_comp_words_by_ref -n : cur words

    # lookup for command
    for word in ${words[@]:1}; do
        if [[ $word != -* ]]; then
            com=$word
            break
        fi
    done

    # completing for an option
    if [[ ${cur} == --* ]]; then
        # opts="--help --quiet --verbose --version --ansi --no-ansi --no-interaction --root-dir --skip-config --skip-root-check --skip-core-commands"
        opts="--help"

        case "$com" in

        cron)
            opts="${opts} --service --update"
            ;;

        ssl)
            opts="${opts} --install --configure --pull --push"
            ;;

        esac

        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi

    # completing for a command
    if [[ $cur == $com ]]; then

        coms=()
        for _com in $(ductn sys:completion:commands); do
            coms+=($_com)
        done

        separator=" "
        coms="$(printf "${separator}%s" "${coms[@]}")"
        coms="${coms:${#separator}}"

        COMPREPLY=($(compgen -W "${coms}" -- ${cur}))
        __ltrim_colon_completions "$cur"

        return 0
    fi
}

complete -o default -F _ductn ductn
