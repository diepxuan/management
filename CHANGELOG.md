# Changelog

Các thay đổi đáng chú ý của dự án được ghi tại đây. Debian package revision đầy đủ được duy trì trong [`src/debian/changelog`](src/debian/changelog).

## 5.7.2 - 2026-07-20

Release note vận hành: [`docs/UPDATE-2026-07-20-ductncli-extend.md`](docs/UPDATE-2026-07-20-ductncli-extend.md).

### Added

- `ductncli` hỗ trợ thêm các AI agent CLI: `freebuff`, `claude`, `gemini`, `aider`, `llm`, `aichat`, `cursor`, `windsurf`, `continue`, `goose`, `qwen`, `chatgpt`, `sgpt`, `mod`.
- Hỗ trợ file cấu hình `~/.config/ductn/config.yml` (hoặc `$XDG_CONFIG_HOME/ductn/config.yml`) để ghi đè registry mặc định: thêm agent, sửa `args` / `description`, tắt agent qua `enabled: false`.
- Tự tạo `config.yml` mặc định trên lần chạy đầu tiên nếu file chưa tồn tại; file seed chứa 4 entry `codex`, `openclaw`, `hermes`, `freebuff`. Bỏ qua khi đặt biến `DuctnCLI_SKIP_DEFAULT_CONFIG`.
- Hỗ trợ override `args` cho từng agent qua biến môi trường `DuctnCLI_AGENT_ARGS_<NAME>`.
- Menu tương tác đánh số theo danh sách agent **đã cài** trên host; agent chưa cài bị ẩn khỏi menu và bị từ chối nếu truyền trực tiếp (kể cả khi có trong config).

### Changed

- `ductncli` không còn hardcode ba agent `hermes` / `codex` / `openclaw`. Logic chuyển sang đọc registry từ `_resolve_agents()` để có thể mở rộng.
- Thông báo lỗi `Unknown agent: ...` liệt kê agent đang thực sự khả dụng trên host.
- YAML loader hỗ trợ thêm flow style (`[a, b]`, `{a: 1}`) để file mặc định seed tự viết được parse lại tròn.

### Notes

- Không thêm dependency Python mới; YAML parser viết tay (~180 dòng) trong `src/utils/cli.py`. Người dùng cần YAML phức tạp hơn (anchor, alias, multi-doc) có thể cài `python3-yaml` rồi chờ release sau.
- Wrapper packages `ductn-ll`, `ductn-m2`, `ductn-lar` không đổi version (vẫn `1:1.0.0+ppa~1`).

## 5.7.1 - 2026-07-05

Release note vận hành: [`docs/UPDATE-2026-07-05-release-5.7.1.md`](docs/UPDATE-2026-07-05-release-5.7.1.md).

### Changed

- Tách `ductn-ll`, `ductn-m2` và `ductn-lar` thành ba Debian source package độc lập.
- Đặt upstream version khởi đầu của từng package wrapper thành `1.0.0`; `ductn-ll` dùng Debian epoch `1` để nâng cấp an toàn từ version `5.x`.
- Giữ package chuyển tiếp rỗng `m2` và `lar` trong source chính để tự động cài `ductn-m2` và `ductn-lar`.
- Giữ nguyên CLI công khai `ll`, `m2`, `lar`.
- `src/build.sh` là entrypoint duy nhất để build và publish bốn source package; workflow chính giữ một job build.

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
