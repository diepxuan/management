# Update: Deprecate HTTPD Commands (2026-05-27)

## Summary

Gỡ toàn bộ nhóm lệnh `httpd:*` khỏi `ductn` package command surface. Bash implementation đã nằm trong `deprecated/src/var/lib/httpd.sh`; Python implementation được chuyển từ `src/utils/httpd.py` sang `deprecated/src/utils/httpd.py`.

## Commands Removed

| Command | Description | Status |
|---------|-------------|--------|
| `httpd:install` | Install Apache/web server packages | Removed |
| `httpd:config` | Configure Apache virtual host | Removed |
| `httpd:restart` | Restart Apache service | Removed |
| `httpd:config:sites` | List configured Apache sites | Removed |

## Files Changed

| Before | After | Action |
|--------|-------|--------|
| `src/utils/httpd.py` | `deprecated/src/utils/httpd.py` | `git mv` |
| `deprecated/src/var/lib/httpd.sh` | unchanged | already deprecated |
| `src/utils/__init__.py` | removed `from . import httpd` | edit |

## Reason

HTTPD/web-server provisioning touches Apache packages, vhost config, service restart, and system paths. The active package should not expose these commands until the workflow is reviewed as a dedicated web-server management feature.

## Validation

- `python3 -m compileall src/utils`
- `./ductn commands | tr ' ' '\n' | grep '^httpd'` returns no commands
- `git diff --check`

## Recovery

If these commands are needed again, restore `deprecated/src/utils/httpd.py` to `src/utils/httpd.py`, re-add `from . import httpd` in `src/utils/__init__.py`, then review and test each command before release.
