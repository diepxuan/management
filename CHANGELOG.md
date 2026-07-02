# Changelog

Các thay đổi đáng chú ý của dự án được ghi tại đây. Debian package revision đầy đủ được duy trì trong [`src/debian/changelog`](src/debian/changelog).

## 5.7.0 - 2026-07-02

Release note vận hành: [`docs/UPDATE-2026-07-02-release-5.7.0.md`](docs/UPDATE-2026-07-02-release-5.7.0.md).

### Added

- Hỗ trợ mở OpenClaw TUI bằng `ductncli openclaw [path]`.
- Hỗ trợ project shortcut `/data/<path>`.
- Resolve real path của agent binary với fallback cho pnpm, npm, apt và Homebrew.

### Changed

- `service:status` giữ nguyên output chi tiết từ `systemctl status` hoặc `launchctl print`.

### Removed

- Loại bỏ `dns:watch` và cơ chế tự động chuyển DNS sang `10.0.0.103`.

### Fixed

- Tương thích type annotations trên Python 3.9 cho module SSL và virtualisation.

## Lịch sử trước 5.7.0

Xem [`src/debian/changelog`](src/debian/changelog).
