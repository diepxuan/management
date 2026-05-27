# Update: APT Command Review and Refactor (2026-05-27)

## Summary

Review và refactor nhóm lệnh `apt:*` trong `ductn` package. Mục tiêu là giữ các command hữu ích (`apt:check`, `apt:install`, `apt:remove`, `apt:uninstall`) nhưng giảm rủi ro shell injection và hành vi package-manager không rõ ràng.

## Commands Reviewed

| Command | Status | Notes |
|---------|--------|-------|
| `apt:check <package>` | Refactored | Dùng `dpkg-query` argv list, không `shell=True` |
| `apt:install <packages...>` | Refactored | Dùng `apt-get install -y`, skip package đã installed |
| `apt:remove <packages...>` | Refactored | Dùng `apt-get purge -y` rồi `apt-get autoremove -y --purge` |
| `apt:uninstall <packages...>` | Kept | Alias của `apt:remove` |
| `apt:fix [--force]` | Reviewed | Safe mode implemented; force mode intentionally not implemented yet |

## Key Changes

- Bỏ `shell=True` khỏi các flow đã refactor.
- Validate package name bằng allowlist regex: `^[A-Za-z0-9][A-Za-z0-9+._:-]*$`.
- Dùng `apt-get` thay vì `apt` cho script/automation.
- `apt:install` gom các package còn thiếu rồi install một lần.
- `apt:remove` tách rõ purge và autoremove.
- Command failure trả về non-zero qua `sys.exit(1)`.
- Invalid package name trả về `sys.exit(2)`.

## apt:fix Recommendation

### Non-force mode

Non-force là mode an toàn mặc định. Không kill process và không xóa lock files thủ công.

Nên làm:

```bash
dpkg --configure -a
apt-get -f install -y
```

Mục tiêu:
- Repair dpkg state bị interrupted.
- Hoàn tất dependency/configuration còn dở.
- Không phá lock nếu apt/dpkg thật sự đang chạy.

### Force mode

`--force` nên chỉ dùng khi đã xác minh lock/process bị stale.

Khác biệt đề xuất:

| Mode | Kill apt/dpkg process | Remove lock files | Use case |
|------|------------------------|-------------------|----------|
| non-force | No | No | Repair an toàn sau interrupted install |
| `--force` | Yes, after detecting stale holder | Yes, after detection | Lock bị kẹt do process chết/crash |

Rủi ro của `--force`:
- Kill nhầm apt/dpkg đang chạy hợp lệ.
- Xóa lock trong khi process thật còn dùng database.
- Có thể làm hỏng `/var/lib/dpkg/status` hoặc để dpkg half-configured.

Vì vậy `apt:fix --force` hiện **chưa implement destructive cleanup**. Command báo lỗi rõ và exit `2`. Nếu cần bật, phải thêm lock-holder detection bằng `fuser`/`lsof`, report PID/command, rồi mới cho phép force.

## Tests

Thêm `tests/unit/test_apt.py`:

- `apt:check` installed/missing/invalid package.
- `apt:install` skip installed, install missing, sudo prefix, failure non-zero.
- `apt:remove` purge + autoremove, sudo prefix, invalid package.

## Validation

```bash
python3 -m unittest tests.unit.test_apt -v
python3 -m compileall src/utils
./ductn commands | tr ' ' '\n' | grep '^apt:'
git diff --check
```
