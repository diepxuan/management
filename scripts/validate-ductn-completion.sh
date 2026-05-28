#!/usr/bin/env bash
set -euo pipefail

# Usage: bash scripts/validate-ductn-completion.sh [completion_file]
#
# Smoke test for ductn bash completion.
# Verifies:
#   1. Syntax check of completion script
#   2. Cache-based completion for installed command: ductn ap<TAB>
#   3. Dev wrapper fallback for ./ductn ap<TAB>
#
# Independent of an installed ductn binary — uses a temporary cache file.

completion_file="${1:-src/ductn/usr/share/bash-completion/completions/ductn}"
cache_file="/tmp/ductn-commands-smoke-test"

if [[ ! -f "$completion_file" ]]; then
  echo "ERROR: completion file not found: $completion_file" >&2
  exit 1
fi

# 1. Syntax check
bash -n "$completion_file"

# 2. Prepare fake command cache
printf 'apt:check apt:fix test:cache\n' > "$cache_file"

# shellcheck source=/dev/null
source "$completion_file"

# 3. Test: installed command uses cache
COMP_WORDS=(ductn ap)
COMP_CWORD=1
DUCTN_COMMANDS_CACHE="$cache_file"
_ductn_completions

if ! printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:check'; then
  echo "FAIL: cache-based completion missing apt:check" >&2
  exit 1
fi
if ! printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:fix'; then
  echo "FAIL: cache-based completion missing apt:fix" >&2
  exit 1
fi

# 4. Test: dev wrapper with explicit cache override still uses cache
COMP_WORDS=(./ductn ap)
COMP_CWORD=1
DUCTN_COMMANDS_CACHE="$cache_file"
_ductn_completions

if ! printf '%s\n' "${COMPREPLY[@]}" | grep -qx 'apt:check'; then
  echo "FAIL: dev wrapper with explicit cache missing apt:check" >&2
  exit 1
fi

# 5. Test: dev wrapper without cache falls back to runtime (only if binary available)
if command -v ./ductn &>/dev/null || [[ -x ./ductn ]]; then
  COMP_WORDS=(./ductn ap)
  COMP_CWORD=1
  unset DUCTN_COMMANDS_CACHE
  _ductn_completions
  # Fallback should return real commands; at least one should match
  if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
    echo "FAIL: dev wrapper fallback returned no completions" >&2
    exit 1
  fi
else
  echo "SKIP: ./ductn binary not available, skipping fallback test"
fi

echo "ductn completion validation OK"
