# Update: Deprecate UFW Commands (2026-05-27)

## Summary

Gỡ toàn bộ nhóm lệnh `ufw:*` khỏi `ductn` package command surface. Bash implementation đã nằm trong `deprecated/src/var/lib/ufw.sh`; Python implementation được chuyển sang `deprecated/src/utils/ufw.py` và không còn được import/register trong active CLI.

## Removed Commands

- `ufw:disable`
- `ufw:geoip:uninstall`
- `ufw:geoip:allow:cloudflare`
- `ufw:geoip:allowCloudflare`
- `ufw:fail2ban:uninstall`
- `ufw:iptables:uninstall`

## Files

| Path | Status |
|------|--------|
| `deprecated/src/var/lib/ufw.sh` | Deprecated Bash source |
| `src/utils/ufw.py` → `deprecated/src/utils/ufw.py` | Deprecated Python implementation |

## Active Import Removed

`src/utils/__init__.py` không còn import:

```python
from . import ufw
```

## Reason

UFW/firewall commands có tính destructive và production-sensitive. Không giữ trong command surface mặc định của `ductn` package.

## Validation

```bash
python3 -m compileall src/utils
python3 -m unittest tests.unit.test_modules -v
./ductn commands | tr ' ' '\n' | grep '^ufw'
# expected: no output, exit 1
```
