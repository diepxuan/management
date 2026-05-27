# Update: Deprecate SSH Commands (2026-05-27)

## Summary

Loại bỏ nhóm lệnh `ssh:*` khỏi `ductn` package. File Bash và Python liên quan được chuyển sang `deprecated/` để tham khảo lịch sử.

## Commands Removed

| Command | Description | Status |
|---------|-------------|--------|
| `ssh:cleanup` | Dọn dẹp authorized_keys, loại bỏ dòng trùng | 🚫 Removed |
| `ssh:install` | Tạo public key từ private key, fix permissions | 🚫 Removed |
| `ssh:copy` | Copy SSH key tới remote server | 🚫 Removed |

## Files Changed

| Before | After | Action |
|--------|-------|--------|
| `src/var/lib/ssh.sh` | `deprecated/src/var/lib/ssh.sh` | `git mv` |
| `src/utils/ssh.py` | `deprecated/src/utils/ssh.py` | `git mv` |
| `src/utils/__init__.py` | Removed `from . import ssh` | Edit |
| `TASKS.md` | Task 1.5 → DEPRECATED, Task 5.6.1-004 added | Edit |
| `README.md` | Mention ssh deprecated | Edit |
| `src/debian/changelog` | Entry for 5.6.1+ppa~1 | Edit |

## Design Decision

Nhóm `ssh:*` command thao tác trực tiếp với private keys, authorized_keys và remote access. Việc gói các lệnh này vào package mặc định tiềm ẩn rủi ro bảo mật nếu sử dụng sai. Không có Python implementation nào hoàn thiện và được review kỹ để thay thế bash script.

## Recovery

Nếu cần khôi phục các lệnh này, revert commit deprecate ssh hoặc copy file từ `deprecated/` về vị trí cũ và re-import trong `__init__.py`.
