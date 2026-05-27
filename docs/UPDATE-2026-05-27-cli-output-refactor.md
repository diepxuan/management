# Update: Refactor ductn CLI Output (2026-05-27)

## Summary

Refactor output của `./ductn` để gọn, rõ và chuyên nghiệp hơn. Trước đây `argparse` in toàn bộ command choice trong usage, làm màn hình rất rối và khó đọc. Sau thay đổi, CLI dùng custom parser flow:

- `ductn` không args hiển thị overview ngắn + full command list dạng indented plain text.
- `ductn help` hiển thị command list dạng indented plain text kèm mô tả.
- `ductn commands` giữ output machine-readable một dòng.
- `ductn commands --grouped` hiển thị command list dạng indented plain text.
- Unknown command báo lỗi ngắn, không dump toàn bộ choices.

## Behavior

### `ductn`

Hiển thị:

- Version.
- Usage ngắn.
- Common commands.
- Full command list dạng indented plain text theo group.
- Gợi ý `ductn help` và `ductn <command> --help`.

### `ductn help`

Hiển thị full command list theo group:

```text
apt
  apt:check              Check if package is installed. Usage: ductn apt:check <package>
  apt:fix                Repair APT/dpkg locks and interrupted state. Usage: ductn apt:fix [-f|--force]

ssh
  ssh:cleanup            Dọn dẹp SSH: dedup authorized_keys, fix permissions, hoặc xóa host key cũ.
```

Không còn tình trạng command dài bị render lỗi/ký tự lạ do table wrapping.

### `ductn commands`

Giữ output một dòng để script/automation tiếp tục dùng được:

```bash
./ductn commands
```

### `ductn commands --grouped`

Thêm mode đọc bằng mắt:

```bash
./ductn commands --grouped
```

### Unknown command

Trước đây argparse in `invalid choice` kèm toàn bộ list commands. Sau refactor:

```text
Unknown command: does:not:exist
Run `ductn commands` to list available commands.
Run `ductn help` for grouped help.
```

## Files Changed

- `src/ductn.py` — custom CLI parser/output flow.
- `src/utils/about.py` — grouped help output.
- `src/utils/command.py` — command grouping helpers and `commands --grouped`.
- `tests/unit/test_cli_output.py` — regression tests for clean output.
- `src/debian/changelog` — release note.

## Validation

```bash
python3 -m unittest tests.unit.test_cli_output -v
./ductn
./ductn help
./ductn commands --grouped
```
