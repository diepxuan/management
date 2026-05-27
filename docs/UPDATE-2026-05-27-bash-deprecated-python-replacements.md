# Update: Move Bash Scripts With Python Replacements to Deprecated (2026-05-27)

## Summary

Kiểm tra các Bash script còn trong `src/var/lib/`. Những script đã có Python module tương ứng trong `src/utils/` được chuyển sang `deprecated/src/var/lib/` để tránh duy trì 2 implementation active song song.

## Moved to Deprecated

| Bash script | Python replacement |
|-------------|--------------------|
| `src/var/lib/cronjob.sh` | `src/utils/cronjob.py` |
| `src/var/lib/disk.sh` | `src/utils/disk.py` |
| `src/var/lib/file.sh` | `src/utils/file.py` |
| `src/var/lib/gpg.sh` | `src/utils/gpg.py` |
| `src/var/lib/host.sh` | `src/utils/host.py` |
| `src/var/lib/httpd.sh` | `deprecated/src/utils/httpd.py` (`httpd:*` removed from active package) |
| `src/var/lib/log.sh` | `src/utils/log.py` |
| `src/var/lib/port.sh` | `src/utils/port.py` |
| `src/var/lib/route.sh` | `src/utils/route.py` |
| `src/var/lib/server.sh` | `src/utils/server.py` |
| `src/var/lib/service.sh` | `src/utils/service.py` |
| `src/var/lib/ufw.sh` | `src/utils/ufw.py` |
| `src/var/lib/user.sh` | `src/utils/user.py` |
| `src/var/lib/vm.sh` | `src/utils/vm.py` |

## Remaining Active Bash Scripts

Các file này vẫn còn trong `src/var/lib/` vì chưa có Python module tương ứng hoặc đang là bootstrap/helper shell:

- `completion.sh`
- `curl.sh`
- `dns.technitium.sh`
- `environment.color.sh`
- `environment.sh`
- `environment.text.sh`
- `functions.sh`
- `git.sh`
- `help.sh`
- `ip.sh`
- `main.sh`
- `mssql.sh`
- `os.sh`
- `php.lar.sh`
- `php.m2.sh`
- `php.sh`
- `sys.service.valid.sh`
- `sys.sh`
- `wg.sh`

## Validation

- `python3 -m compileall src/utils`
- `./ductn commands` before/after comparison
- `git diff --check`

## Decision

Không xóa Bash script đã migrate; chỉ chuyển sang `deprecated/` để còn lịch sử tham khảo khi cần diff behavior hoặc rollback.

Không move các `.sh` chưa có Python replacement để tránh mất command/helper cũ.
