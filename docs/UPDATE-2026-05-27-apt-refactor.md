# Update: APT Command Review and Refactor (2026-05-27)

## Summary

Review và refactor nhóm lệnh `apt:*` trong `ductn` package.

Theo yêu cầu mới, package chỉ giữ lại:

- `apt:check <package>`
- `apt:fix [-f|--force]`

Các lệnh package mutation trực tiếp bị gỡ khỏi command surface:

- `apt:install`
- `apt:remove`
- `apt:uninstall`

## Active Commands

| Command | Status | Notes |
|---------|--------|-------|
| `apt:check <package>` | Active | Dùng `dpkg-query` argv list, không `shell=True` |
| `apt:fix [-f|--force]` | Active | Tự detect process giữ lock, không dùng `killall` |

## Removed Commands

| Command | Status | Reason |
|---------|--------|--------|
| `apt:install` | Removed | Package installation nên dùng native apt/apt-get trực tiếp, tránh package tự expose destructive package-manager flow |
| `apt:remove` | Removed | Package removal/purge là destructive; không giữ trong command surface mặc định |
| `apt:uninstall` | Removed | Alias của `apt:remove`, removed cùng command gốc |

## apt:check Behavior

```bash
ductn apt:check bash
# 1

ductn apt:check missing-package
# 0
```

Security:

- Validate package name bằng allowlist regex: `^[A-Za-z0-9][A-Za-z0-9+._:-]*$`.
- Không dùng shell command string.
- Invalid package name exit code `2`.

## apt:fix Behavior

### Normal mode: `ductn apt:fix`

Flow:

1. Tìm process đang giữ APT/dpkg lock bằng `fuser` trên các lock files:
   - `/var/lib/apt/lists/lock`
   - `/var/cache/apt/archives/lock`
   - `/var/lib/dpkg/lock`
   - `/var/lib/dpkg/lock-frontend`
2. Nếu `fuser` không tìm được holder, fallback scan process apt-like (`apt`, `apt-get`, `aptitude`, `dpkg`, `unattended-upgrade`).
3. Nếu có process đang giữ lock:
   - Không kill.
   - Báo PID + command.
   - Exit code `3`.
   - Hướng dẫn Sếp chờ process hoàn tất hoặc dùng `apt:fix --force` / `apt:fix -f` nếu process treo/lỗi lock.
4. Nếu không có process giữ lock:
   - Remove stale lock files.
   - Chạy repair:
     ```bash
     dpkg --configure -a
     apt-get -f install -y
     ```

### Force mode: `ductn apt:fix --force` hoặc `ductn apt:fix -f`

Flow:

1. Detect exact PIDs đang giữ lock.
2. Kill đúng các PID đó bằng `SIGTERM`.
3. Không dùng `killall`.
4. Remove lock files.
5. Chạy repair:
   ```bash
   dpkg --configure -a
   apt-get -f install -y
   ```

## Difference: normal vs force

| Mode | Kill process | Remove lock files | Repair dpkg/apt | Use case |
|------|-------------|-------------------|-----------------|----------|
| `apt:fix` | No | Chỉ khi không có process giữ lock | Yes | Repair an toàn, hoặc unlock stale lock không có holder |
| `apt:fix --force` / `apt:fix -f` | Yes, exact PID only | Yes | Yes | Process giữ lock bị treo/lỗi, cần kill đúng PID |

## Tests

`tests/unit/test_apt.py` covers:

- Command surface chỉ còn `apt:check`, `apt:fix`.
- `apt:check` installed/missing/invalid package.
- `apt:fix` no holder → remove lock + repair.
- `apt:fix` holder without force → report PID and exit `3`.
- `apt:fix --force` / `-f` → kill exact PID, remove lock, repair.

## Validation

```bash
python3 -m unittest tests.unit.test_apt -v
python3 -m compileall src/utils
./ductn commands | tr ' ' '\n' | grep '^apt:'
git diff --check
```
