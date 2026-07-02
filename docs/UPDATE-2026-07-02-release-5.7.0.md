# Release 5.7.0

## Mục đích

Phát hành các thay đổi đã merge trong PR #48, #49 và #50 thành Debian package `5.7.0+ppa~1`.

## Thay đổi chính

- Gỡ `dns:watch` và cơ chế tự chuyển DNS sang `10.0.0.103`.
- Sửa tương thích Python 3.9 và hiển thị đầy đủ `service:status`.
- Thêm OpenClaw TUI cho `ductncli`, project shortcut `/data/<path>` và binary resolver đa nguồn.

## Cách sử dụng

```bash
ductn --version
sudo ductn service:status
ductncli openclaw <project>
```

`ductncli openclaw portal` ưu tiên workspace `/data/portal` khi thư mục tồn tại và chạy `openclaw tui` bằng real path của binary.

## File liên quan

- `src/debian/changelog`
- `CHANGELOG.md`
- `README.md`
- `TASKS.md`
- `src/utils/cli.py`
- `src/utils/system_service.py`
- `src/utils/dns.py`

## Dependencies

- Python 3.9 trở lên.
- `openclaw` phải được cài và executable khi dùng OpenClaw TUI.
- Binary agent có thể đến từ PATH, pnpm, npm, apt hoặc Homebrew.

## Breaking changes

- Command `dns:watch` không còn tồn tại.
- `ductnd` không còn tự động thay đổi DNS sang `10.0.0.103`.

## Troubleshooting

- Nếu OpenClaw không được tìm thấy, kiểm tra `which openclaw` và quyền executable của binary.
- Nếu `service:status` báo không tìm thấy service, cài hoặc đăng ký `ductnd` với systemd/launchd trước.
- Nếu workspace không resolve được, kiểm tra path trực tiếp, `~/`, `/data/`, `~/.openclaw/workspace/projects/` và `~/.hermes/workspace/projects/`.

## Validation

- `ductn --version` trả `5.7.0+ppa~1`.
- `ductn version:newrelease` trả `5.7.1`.
- 9 CLI/service regression tests đạt.
- `git diff --check` đạt.
- Debian changelog được kiểm tra cấu trúc bằng regex; `dpkg-parsechangelog` không có trên môi trường macOS hiện tại.
