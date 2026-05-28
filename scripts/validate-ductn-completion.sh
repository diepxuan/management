#!/usr/bin/env bash
set -euo pipefail

completion_file="${1:-src/ductn/usr/share/bash-completion/completions/ductn}"
cache_file="${DUCTN_COMMANDS_CACHE:-/tmp/ductn-commands-test}"

if [[ ! -f "$completion_file" ]]; then
  echo "ERROR: completion file not found: $completion_file" >&2
  exit 1
fi

bash -n "$completion_file"

printf 'apt:check apt:fix test:cache\n' > "$cache_file"

# shellcheck source=/dev/null
source "$completion_file"

COMP_WORDS=(ductn ap)
COMP_CWORD=1
DUCTN_COMMANDS_CACHE="$cache_file"
_ductn_completions

printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:check'
printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:fix'

COMP_WORDS=(./ductn ap)
COMP_CWORD=1
DUCTN_COMMANDS_CACHE="$cache_file"
_ductn_completions

printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:check'
printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:fix'

echo "ductn completion validation OK"
