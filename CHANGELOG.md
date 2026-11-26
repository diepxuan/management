# Changelog

## 5.8.7 - 2026-11-25

### Removed

- **17 file bash trong `src/var/lib/`** (1 591 dòng). Không file nào từng được
  đóng gói vào `.deb` — `src/debian/ductn.install` chỉ copy
  `src/ductn/var/lib/lxc/hooks/default-hook.sh`. Toàn bộ là code chết trong
  repo. Chi tiết từng phần giữ/bỏ: [docs/SALVAGE-5.8.7.md](docs/SALVAGE-5.8.7.md).
  - Xoá vì đã có Python thay thế: `help.sh`, `curl.sh`, `environment.sh`,
    `wg.sh`, `ductnd.sh.org`.
  - Salvage rồi xoá: `git.sh`, `main.sh`, `environment.color.sh`,
    `environment.text.sh`, `os.sh`, `completion.sh`, `php.sh`, `mssql.sh`,
    `macos/os.sh`, `macos/dns.sh`, `macos/wg.sh`, `macos/sshfs.sh`.

### Fixed

- **`git:detrack` xoá file khỏi index thay vì chỉ bỏ theo dõi**
  (`src/utils/git_utils.py`): Python chạy `git rm --cached`, trong khi bash
  gốc chạy `git update-index --no-assume-unchanged`. Hai lệnh khác hẳn nhau —
  ai dùng `ductn git:detrack` trước bản này có thể đã vô tình xoá file khỏi
  repo. `git:untrack` cũng từ alias sai thành
  `git update-index --assume-unchanged`.
- **`git:viewuntrack` lọc sai nguồn**: nay parse `git ls-files -v` lấy dòng
  bắt đầu bằng chữ thường (đúng bash), thay vì `git status --short` lọc `??`.
- **`git:tag:cleanup` không xoá gì**: trước chỉ in danh sách. Nay giữ N tag
  đầu (mặc định 5), xoá phần còn lại trên `origin` rồi `fetch --prune`.
- **`git:configure --global` thiếu phân nửa cấu hình**: bổ sung
  `core.fileMode=false`, `core.autocrlf=false`, `core.eol=lf`, `gc.auto=0`,
  `receive.denyCurrentBranch=updateInstead`, và sinh `~/.gitignore` + trỏ
  `core.excludesfile` vào đó (template ~100 dòng từ bash).
- **`disk:check` đo sai thứ** (`src/utils/disk.py`): trước gọi
  `smartctl -a /dev/sda` cho cả ba "sector size". Bash gốc đo throughput ghi
  tuần tự bằng `dd` (8k×10k = 80 MB, 512k×1k = 512 MB). Nay port đúng `dd`;
  phần SMART tách thành `disk:health [device]`.
- **`php:composer:install` chạy installer không kiểm tra chữ ký**: bash tải
  SHA384 từ `composer.github.io/installer.sig` và so trước khi chạy; Python
  có comment `# Verify signature (skip for now)`. Nay verify thật, và tải vào
  tmpdir thay vì thư mục home.
- **`os:codename` / `os:release` / `os:distro` trả rỗng trên macOS**
  (`src/utils/system_os.py`): module `distro` đọc `/etc/os-release`, file
  không tồn tại trên macOS. Nay nhánh `darwin` dùng `sw_vers` như
  `macos/os.sh` gốc.
- **`zfs:disk:replace_boot_disk` (tên cũ) không dùng được cho đĩa boot thật**:
  bản cũ gọi `zpool replace <pool> <new_disk>`, thiếu đuôi `-part3` và thiếu
  bước `sgdisk`. Nay delegate sang `zfs:disk:replace:boot` kèm cảnh báo
  deprecated.
- **`interface:service` crash trên Linux** (`src/utils/interface.py`):
  `get_active_service()` gọi `route get default` — cú pháp macOS — trên mọi
  nền tảng, nên trên Linux lệnh trả exit 3 và Python ném
  `CalledProcessError`. Hàm cũng gọi `networksetup` mà không kiểm tra nền
  tảng. Nay chỉ dùng `networksetup` trên Darwin; trên Linux trả interface
  mặc định (`ip route show default`). Phát hiện qua smoke test 128 command.
- **Hai test fail thường trực đã được sửa**: `test_modules.py` còn tham chiếu
  `utils.user` (xoá từ 5.6.4) và `test_cli_output.py` còn kỳ vọng dòng
  `cli:tmux:install` (xoá từ 5.6.6). Suite từ 182 test / 2 fail thành
  **343 test / 0 fail**.

### Added

- `src/utils/style.py` — palette ANSI + ký hiệu trạng thái (`ok()`/`fail()`/
  `info()`), salvage từ `environment.color.sh` và `environment.text.sh`. Tự
  tắt màu khi không phải TTY hoặc có `NO_COLOR`.
- `src/utils/mssql.py` — migrate `mssql.sh` (230 dòng). Repo setup viết lại
  bằng keyring + `signed-by` thay `apt-key` (đã bị bỏ ở Debian 12 /
  Ubuntu 24.04). Command: `sqlsrv:apt`, `sqlsrv:install`, `sqlsrv:php:install`,
  `sqlsrv:php:enable`, `sqlsrv:php:disable` + alias `mssql:*`.
- `src/utils/fleet.py` — `fleet:status` kiểm tra phiên bản `ductn` trên từng
  host qua SSH, salvage nửa inventory của `main.sh`.
- `src/utils/completion_paths.py` — `completion:path <tool>` và
  `completion:exists <tool>`, gộp 6 function gần trùng của `completion.sh`.
- `src/utils/wireguard_macos.py` — `wg:*` (10 command) cho macOS.
- `src/utils/sshfs_macos.py` — `sshfs:*` (5 command) cho macOS, bỏ hardcode
  host/key của một máy cụ thể.
- `zfs:disk:replace:disk <pool> <old> <new>` — thay đĩa hỏng trong pool
  RAIDZ/mirror (`zpool replace -f`).
- `zfs:disk:replace:boot <old_disk> <new_disk>` — thay đĩa boot Proxmox:
  `sgdisk -R` copy partition table, `sgdisk -G` cấp GUID mới, `zpool replace`.
- `zfs:disk:format:boot:disk <partition>` — chạy `proxmox-boot-tool format`
  + `init` có xác nhận (trước chỉ in cảnh báo).
- `vm:agent:install` (alias `pve:vm`) — cài `qemu-guest-agent`.
- `vm:command '<json>'` — chạy danh sách lệnh từ payload Proxmox.
- `file:chmod <path>`, `file:chmod:files <mode> <dir>`,
  `file:chmod:dirs <mode> <dir>`.
- `hash:md5` — chuỗi ngẫu nhiên 20 ký tự (dùng `secrets`).
- `ssh <host> <command>` — chạy lệnh từ xa, giữ `-T`.
- `dns:set <ip>...` và `dns:status` cho macOS.
- `log:config:store`, `log:config:mssql` — expose hai hàm đã có sẵn.
- `docs/MSSQL-AD-SPN.md` — runbook Kerberos/AD cho SQL Server (không ship
  thành command vì chứa mật khẩu domain trong argv).
- `docs/SALVAGE-5.8.7.md` — ghi lại từng phần giữ/bỏ khi xoá 17 file bash.
- 161 test mới: `test_style.py` (16), `test_helpers.py` (13),
  `test_git_utils.py` (24), `test_mssql.py` (26), `test_salvage.py` (33),
  `test_macos_salvage.py` (27), `test_interface.py` (13);
  `test_disk.py` viết lại (23).

### Changed

- Command tăng **87 → 128**.
- `TASKS.md` cập nhật theo thực tế: 37 task completed, 0 pending. Nhiều task
  ghi PENDING từ 2026-07-20 nhưng thực tế đã xong (cronjob, disk, port, git,
  php, gpg, curl, server, env_detect, helpers, main).

## 5.8.6 - 2026-09-05

### Fixed

- **Rò rỉ RAM của `ductnd.service`** (`src/utils/serviceScheduler.py`,
  `src/utils/serviceContext.py`): mỗi lần task chạy, một
  `threading.Thread` được tạo và đăng ký vào `ServiceContext.threads`
  nhưng **không bao giờ được gỡ**. Với `vm_sync` (10s) và
  `route_monitor` (5s) là ~25.900 Thread object/ngày; sau 11 ngày host
  giữ ~290.000 object ≈ **700 MB RSS** (đo thực tế 2,5 KB/Thread).
  - Thread giờ được `unregister_thread()` trong khối `finally`.
  - Thread chạy dạng `daemon=True` để không chặn shutdown.
  - `join_all()` dọn sạch cả `threads` và `_running` sau khi join.
- **Chống chạy chồng task**: nếu lần chạy trước của cùng task còn sống,
  tick hiện tại bị bỏ qua. Tránh tích tụ thread khi thời gian chạy dài
  hơn interval (ví dụ `vm_sync` retry DNS ~20s trong khi interval 10s).
- **Log bị nhân đôi**: unit systemd redirect stdout vào
  `/var/log/ductnd/ductnd.log` trong khi Python cũng mở
  `RotatingFileHandler` trên đúng file đó. Unit giờ set
  `Environment=RUNNING_UNDER_SYSTEMD=1` và để journald thu stdout;
  Python bỏ handler file khi biến này bật. Trước đây 56 dòng
  "Scheduler started" cho ~28 lần khởi động thật.
- **`StartLimitIntervalSec` / `StartLimitBurst` đặt sai section**: đã
  chuyển từ `[Service]` sang `[Unit]` (systemd trước đó bỏ qua và log
  "Unknown key ... in section [Service]").
- **`host:domain` trả về domain rác**: `_host_domain()` ưu tiên directive
  `search` trong `/etc/resolv.conf`, sau đó mới parse
  `socket.getfqdn()`, cuối cùng là `DEFAULT_DOMAIN`. Ứng viên dạng IPv4
  bị loại — host Proxmox có `/etc/hosts` chứa `postgresql.192.168.1.1`
  trước đây cho ra "domain" `192.168.1.1`, zone này không tồn tại trên
  DNS server.
- **`vm:sync` thoát im lặng khi DNS API báo lỗi**: API trả HTTP 200 kèm
  `{"status":"error"}` (zone không tồn tại) trước đây khiến lệnh trả về
  0, không log, không record nào được publish. Giờ log `error` kèm
  domain, zone và thông điệp lỗi.

### Added

- `tests/unit/test_host.py`: 20 test pin hành vi `_domain_from_resolv_conf()`,
  `_looks_like_ipv4()` và thứ tự ưu tiên của `_host_domain()`.
- `tests/unit/test_service_scheduler.py`: 15 test pin vòng đời thread
  (register/unregister, chống leak, guard chống chồng, daemon, dọn dẹp
  khi task raise exception).
- `tests/unit/test_vm.py`: thêm 2 test cho log lỗi API và nhánh thành công.

## 5.8.5 - 2026-09-05

### Fixed

- `utils.addr._ip_locals()` giờ loại bỏ thêm toàn bộ `172.16.0.0/12`
  (RFC1918, dùng nhiều cho Docker bridge / mạng local-only) ngoài
  `127.0.0.0/8` loopback. Trước đây các IP như `172.17.0.1` (Docker
  default bridge) hoặc `172.18.0.1` (user-defined bridge, vd của
  `openclaw.diepxuan.corp`) bị đẩy lên internal DNS API làm A record
  cho hostname VM, khiến VM không truy cập được từ bất kỳ host nào
  khác ngoài host sở hữu bridge đó.
- `vm:sync` không cần thay đổi — nó vẫn đọc qua `_ip_locals()` nên tự
  động hưởng lợi từ filter mới.

### Added

- `tests/unit/test_addr.py`: 5 test pin behavior filter loopback +
  172.16.0.0/12 + DOWN interface + dedup + subprocess error.
- `tests/unit/test_vm.py::test_vm_sync_deletes_stale_records`: pin hành
  vi xoá record cũ không còn trong `_ip_locals()`.

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
