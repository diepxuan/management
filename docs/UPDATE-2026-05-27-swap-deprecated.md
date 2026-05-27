# Update 2026-05-27 - Deprecate swap commands

## Purpose

The `swap:*` command group is removed from the active `ductn` package command surface.

## Review result

Legacy Bash source:

- `src/var/lib/swap.sh`

Commands found:

- `swap:remove`: runs `swapoff -v /swapfile` and removes `/swapfile`
- `swap:install`: removes/recreates `/swapfile`, allocates 2G, runs `mkswap`, then `swapon`

Python implementation found:

- `src/utils/swap.py`
- registered commands `d_swap_remove` and `d_swap_install`

## Decision

Do not ship active swap management commands in `ductn`.

Reason:

- These commands directly manipulate `/swapfile`.
- `swap:remove` is destructive for host memory configuration.
- Swap lifecycle should not be exposed as a default package command without a dedicated, reviewed workflow.

## Files changed

- Moved `src/var/lib/swap.sh` to `deprecated/src/var/lib/swap.sh`
- Moved `src/utils/swap.py` to `deprecated/src/utils/swap.py`
- Removed `from . import swap` from `src/utils/__init__.py`
- Updated `TASKS.md`
- Updated `README.md`
- Updated `src/debian/changelog`

## Commands removed

```text
swap:remove
swap:install
```

## Validation

```bash
python3 -m compileall src/utils
bash -n deprecated/src/var/lib/swap.sh
! ./ductn commands | tr ' ' '\n' | grep '^swap:'
git diff --check
```

## Compatibility note

Any external workflow still calling `ductn swap:remove` or `ductn swap:install` must be migrated away. The old implementations remain in `deprecated/` for reference only.
