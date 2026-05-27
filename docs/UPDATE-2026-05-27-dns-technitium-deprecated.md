# Update: Deprecate DNS Technitium Commands (2026-05-27)

## Summary

Gỡ toàn bộ nhóm lệnh `dns:technitium:*` khỏi `ductn` package command surface. Các implementation gốc được chuyển sang `deprecated/` để giữ lịch sử tham khảo, không còn được import/register trong active CLI.

## Removed Commands

- `dns:technitium:install`
- `dns:technitium:record:list`
- `dns:technitium:recordList`
- `dns:technitium:get` (legacy target trong backlog/Bash, không active trước khi remove)

## Files Moved

| From | To |
|------|----|
| `src/utils/dns_technitium.py` | `deprecated/src/utils/dns_technitium.py` |
| `src/var/lib/dns.technitium.sh` | `deprecated/src/var/lib/dns.technitium.sh` |

## Active Import Removed

`src/utils/__init__.py` không còn import:

```python
from . import dns_technitium
```

## Reason

Technitium là integration cụ thể, không còn giữ trong command surface mặc định của `ductn` package.

## Validation

```bash
python3 -m compileall src/utils
python3 -m unittest tests.unit.test_modules -v
./ductn commands | tr ' ' '\n' | grep '^dns:technitium'
# expected: no output, exit 1
```
