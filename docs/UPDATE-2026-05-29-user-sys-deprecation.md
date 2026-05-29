# Update 2026-05-29: Deprecate user commands and legacy sys commands

## Version

`5.6.4+ppa~1`

## Summary

Version 5.6.4 removes the active `user:*` command group and trims the legacy `src/var/lib/sys.sh` script to update-only compatibility.

## Deprecated commands

Removed from the active Python command registry:

- `user:new`
- `user:config`
- `user:config:bash`
- `user:config:chmod`
- `user:config:admin`
- `user:is_sudoer`

Removed/deprecated from legacy `sys.sh`:

- `sys:init`
- `sys:sysctl`
- `sys:clean`
- `isenabled`

## Kept behavior

The legacy update commands remain available in `src/var/lib/sys.sh`:

- `update`
- `__selfupdate`
- `__self-update`
- `sys:upgrade`

These still run:

```bash
apt update
apt install --only-upgrade ductn -y --purge --auto-remove
```

## File moves

The active Python implementation was preserved for history:

```text
src/utils/user.py -> deprecated/src/utils/user.py
```

The old Bash implementation was already deprecated:

```text
deprecated/src/var/lib/user.sh
```

## Impact

`sys:init` used to call `user:config`; both are intentionally deprecated together. New setup flows should not depend on automatic user shell/permission/admin setup from `ductn`.

## Validation

- Active command surface must not contain `user:*` commands.
- `src/utils/__init__.py` must not import `user`.
- `src/var/lib/sys.sh` must pass `bash -n`.
