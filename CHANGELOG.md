# Changelog

## 5.8.4 - 2026-07-24

### Fixed

- `ductncli` autocompletion không còn hardcode `hermes codex openclaw`.
  Completion giờ gọi `ductncli --list` (Python trả về tên các agent có
  binary thật trên host), nên:
  - `claude` (và bất kỳ agent nào khác trong `AGENTS_DEFAULT` đã cài) sẽ
    xuất hiện kể cả khi chưa có trong `~/.config/ductn/config.yml`.
  - Agent trong config nhưng chưa cài sẽ bị ẩn khỏi TAB (trước đây luôn
    được suggest, dù Python từ chối khi chạy).
- `/etc/profile.d/ductn-prompt.sh` không còn đóng băng `(branch)` sau lần
  set PS1 đầu tiên. Script giờ gắn `__ductn_prompt_command` vào
  `PROMPT_COMMAND`, mỗi prompt sẽ rebuild PS1 theo git branch của CWD
  hiện tại. PROMPT_COMMAND cũ (ví dụ `update_terminal_cwd` của
  Ubuntu/Debian) được giữ nguyên và prepend hook của mình trước.

### Added

- `ductncli --list` / `--list-installed`: in tên các agent đã cài, một
  tên trên một dòng. Là nguồn dữ liệu duy nhất cho bash completion —
  registry Python là canonical, không bao giờ trôi khỏi bash script.

### Tests

- 11 test mới:
  - `tests/unit/test_cli.py`: 4 test pin hợp đồng `--list` chỉ in agent
    đã cài, alias `--list-installed` hoạt động, host rỗng trả empty,
    auto-seed config vẫn chạy cùng `--list`.
  - `tests/unit/test_completion.py`: 4 test nguồn bash completion trong
    bash thật (stub `ductncli`, gọi `_ductncli_completions` với
    `COMP_WORDS` / `COMP_CWORD` giả lập), xác nhận: chỉ liệt kê agent
    trong `--list`, ẩn agent vắng mặt, filter theo prefix, `bash -n`
    parse sạch.
  - `tests/unit/test_prompt.py`: 3 test pin PROMPT_COMMAND động —
    install khi PS1 default, prepend (không clobber) khi
    PROMPT_COMMAND đã có, PS1 đổi sau `cd` vào git repo.
- Tổng test các module bị động: 153/153 (pre-existing
  `test_modules.utils.user` và `test_cli_output` không liên quan PR).

Các thay đổi đáng chú ý của dự án được ghi tại đây. Debian package revision đầy đủ được duy trì trong [`src/debian/changelog`](src/debian/changelog).

## 5.8.3 - 2026-07-22

### Fixed

- `/etc/profile.d/ductn-prompt.sh` no longer embeds the BSD-incompatible
  inline sed `sed "s/^/ (/;s/$/)/"`. BSD sed on macOS rejected it with
  `unterminated \`s' command` because the trailing `/` was missing before
  `;`. The branch suffix `(branch)` is now rendered via `printf` against a
  local variable, which works identically on GNU sed and BSD sed. Visual
  output unchanged.

### Tests

- 4 new shell-script tests in `tests/unit/test_prompt.py` pinning the fix:
  function body must not contain inline `sed "s/"` or `sed 's/'`, rendered
  PS1 must include `(branch)` inside a git repo, must omit it outside, and
  must never emit the BSD sed unterminated error.

Các thay đổi đáng chú ý của dự án được ghi tại đây. Debian package revision đầy đủ được duy trì trong [`src/debian/changelog`](src/debian/changelog).

## 5.8.0 - 2026-07-22

### Added

- Ship `/etc/profile.d/ductn-prompt.sh` as a Debian conffile. When sourced by
  an interactive bash shell, replaces the default `PS1` with a colored
  `user@host:directory (branch)` prompt that renders the current git branch.
  Coexists safely with `starship`, `oh-my-bash`, `p10k`, `powerlevel`
  (auto-detected and skipped). User opt-out via
  `~/.config/ductn/no-prompt` or `DUCTN_PROMPT_DISABLE=1`.
- New CLI command `ductn prompt status|enable|disable` to inspect and toggle
  the per-user opt-out file.
- 12 new unit tests covering status / enable / disable and
  `XDG_CONFIG_HOME` handling.

### Changed

- `src/debian/ductn.install` now installs `ductn-prompt.sh` into
  `/etc/profile.d/`.
- New `src/debian/ductn.conffiles` registers the prompt script as a
  Debian conffile (preserves local edits on upgrade).

## 5.7.2 - 2026-07-20

Release note vận hành: [`docs/UPDATE-2026-07-20-ductncli-extend.md`](docs/UPDATE-2026-07-20-ductncli-extend.md).

### Added

- `ductncli` hỗ trợ thêm các AI agent CLI: `freebuff`, `claude`, `gemini`, `aider`, `llm`, `aichat`, `cursor`, `windsurf`, `continue`, `goose`, `qwen`, `chatgpt`, `sgpt`, `mod`.
- Hỗ trợ file cấu hình `~/.config/ductn/config.yml` (hoặc `$XDG_CONFIG_HOME/ductn/config.yml`) để ghi đè registry mặc định: thêm agent, sửa `args` / `description`, tắt agent qua `enabled: false`.
- Tự tạo `config.yml` mặc định trên lần chạy đầu tiên nếu file chưa tồn tại; file seed chứa 4 entry `codex`, `openclaw`, `hermes`, `freebuff`. Không đụng vào file đã có sẵn.
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
