# DiepXuan Personal Package

`ductn` là private package của DiepXuan, phát hành qua DiepXuan PPA Package Repository. Dự án ban đầu dùng nhiều Bash script trong `src/var/lib/`; hiện đang được migrate dần sang Python CLI trong `src/ductn.py` và các module `src/utils/`.

## Trạng thái hiện tại

- **Package source:** `diepxuan`
- **Package chính:** `ductn`
- **Package phụ:** `lar`, `m2`, `ductn-ll`
- **Version hiện tại:** xem `src/debian/changelog`
- **CLI mới:** Python, entrypoint `src/ductn.py`
- **Legacy CLI:** Bash scripts trong `src/var/lib/`
- **Migration tracking:** `TASKS.md`

Dự án chưa migrate xong. Một số chức năng Python đã dùng được, nhiều chức năng Bash cũ vẫn còn nằm trong `src/var/lib/` và chưa có bản Python tương đương. Các command đã loại khỏi package được chuyển sang `deprecated/` để tham khảo lịch sử, ví dụ nhóm `swap:*` và `ssh:*` đã bị gỡ khỏi command surface active.

## Mục đích

Package này gom các công cụ vận hành hệ thống nội bộ DiepXuan:

- Quản lý thông tin hệ thống, network, route, DNS, service.
- Hỗ trợ thao tác APT và sửa lỗi repository phổ biến.
- Hỗ trợ môi trường Laravel/Magento thông qua package `lar` và `m2`.
- Cài đặt service, cron, MOTD, bash completion và tiện ích CLI dùng hằng ngày.
- Mở Hermes/Codex trong terminal session qua `ductn cli`/`ductncli`.
- Chuẩn hóa một số workflow vận hành trên Linux/macOS.

## Cài đặt

Cài từ DiepXuan PPA:

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CF8545DBEDD9351A
curl -s https://ppa.diepxuan.com/install.sh | sudo bash
sudo apt install ductn
```

Kiểm tra version:

```bash
ductn -v
```

Ghi chú locale khi cài đặt:

- `postinst` tự cấu hình locale UTF-8 để tránh lỗi/warning khi package gọi CLI hoặc service trong môi trường thiếu locale.
- Ưu tiên `C.UTF-8`.
- Nếu `C.UTF-8` không dùng được, fallback sang `en_US.UTF-8` và tự chạy `locale-gen en_US.UTF-8` khi có thể.
- Package phụ thuộc `locales` để có `locale-gen`/`update-locale` trên Debian/Ubuntu.

## Cách chạy khi phát triển

Chạy trực tiếp từ source:

```bash
./ductn --help
./ductn commands
```

`./ductn` là wrapper dev ở root repo, gọi `src/ductn.sh` và tự xử lý `src/venv`/`uv` nếu có. Ưu tiên dùng wrapper này khi dev test để giống đường chạy package hơn so với gọi trực tiếp `src/ductn.py`.

Cài dependencies Python nếu môi trường chưa có:

```bash
python3 -m pip install -r src/requirements.txt
```

Lưu ý: khi chạy bằng quyền root, module Python cấu hình log tại `/var/log/ductnd/ductnd.log`. Môi trường sandbox/read-only có thể không ghi được path này.

## Kiến trúc

```text
.
├── README.md                 # Tài liệu tổng quan dự án
├── TASKS.md                  # Kế hoạch migrate Bash sang Python
├── ci/                       # Script publish/build package
├── deprecated/               # Mã/config cũ đã tách khỏi path chính
│   └── task/                 # PowerShell Windows scripts đã deprecated
├── docs/                     # Ghi chú cập nhật cấu trúc/config/behavior
├── src/
│   ├── ductn.py              # Python CLI entrypoint
│   ├── ductn.sh              # Wrapper shell cho CLI
│   ├── requirements.txt      # Python dependencies
│   ├── debian/               # Debian packaging metadata
│   ├── ductn/                # Files installed by ductn package
│   ├── utils/                # Python command modules
│   └── var/lib/              # Legacy Bash command library
└── .github/workflows/        # CI build workflow
```

## Python CLI

`src/ductn.py` tạo CLI bằng `argparse`. Các command được đăng ký tự động qua decorator `@register_command` trong `src/utils/registry.py`.

Quy ước hiện tại:

- Function Python dạng `d_dns_clean` được expose thành command `dns:clean`.
- Function Python dạng `d_ip_local` được expose thành command `ip:local`.
- Command list được gom trong `COMMANDS` và in ra bằng `d_commands`.
- Module Python mới nên đặt trong `src/utils/` và import tại `src/utils/__init__.py`.

### Nhóm command Python đã có

| Nhóm | Command/function chính | Mục đích |
|------|------------------------|----------|
| About | `d_help`, `d_version`, `d_version_newrelease` | Help/version |
| Command | `d_commands` | Liệt kê command đã đăng ký |
| Network/IP | `d_ip_local`, `d_ip_locals`, `d_ip_wan` | IP local/WAN |
| Interface | `d_interface_default`, `d_interface_service` | Interface/service active |
| Route | `d_route_default`, `d_route_monitor` | Route mặc định, monitor route |
| DNS | `d_dns_clean`, `d_dns_reset`, `d_dns_disable`, `d_dns_resolved`, `d_dns_watch` | Quản lý DNS Linux/macOS |
| APT | `d_apt_fix`, `d_apt_check` | Kiểm tra package và sửa lock/state APT an toàn |
| Host | `d_host_name`, `d_host_domain`, `d_host_fullname` | Hostname/domain/FQDN |
| OS | `d_os_codename`, `d_os_release`, `d_os_distro`, `d_os_architecture`, `d_os_type` | Thông tin OS |
| System | `d_sys_update`, `d_update`, `d_sys_info` | Update và system info |
| Service | `d_service`, `d_service_install`, `d_service_start`, `d_service_stop`, `d_service_restart`, `d_service_status`, `d_service_watch` | Service daemon |
| Time | `time:timezone`, `timezone:vietnam`, `time:vietnam`, `time:sync`, `time:init` | Timezone Việt Nam và đồng bộ giờ NTP |
| CLI | `cli` | Mở Hermes/Codex qua ductncli (shpool) |
| File | `d_file_cleanpath` | Chuẩn hóa tên/path file |
| VM | `d_vm_info`, `d_vm_sync` | Thông tin VM và sync DNS A record qua DNS API nội bộ |
| Environment | `d_env_detect` | Detect VM/container/environment |
| Alias | `d_alias_ll` | Alias `ll` |

### CLI commands

`ductn cli` là wrapper public để mở Hermes hoặc Codex qua `ductncli` (sử dụng shpool):

```bash
# Chọn agent, workspace mặc định là ~/
ductn cli

# Mở Hermes trong project shortcut ~/.openclaw/workspace/projects/ductnd
# hoặc ~/.hermes/workspace/projects/ductnd
ductn cli ductnd

# Mở Codex bằng profile mặc định của wrapper
ductn cli codex ductnd
```

Ghi chú vận hành:

- Package cài script `/usr/bin/ductncli`; command `ductn cli` exec sang script này để giữ tương thích.
- `ductncli` sử dụng shpool để quản lý terminal sessions, thay thế tmux.
- `ductncli` tự attach session cũ nếu đã tồn tại, tránh tạo session trùng.
- Dependencies runtime: `shpool`, `realpath`, và agent CLI tương ứng (`hermes` hoặc `codex`).

### Time commands

Nhóm command `time:*` dùng để chuẩn hóa timezone và đồng bộ đồng hồ hệ thống:

```bash
# In timezone hiện tại nếu detect được
./ductn time:timezone current

# Set timezone về Việt Nam nếu chưa đúng
./ductn time:timezone
./ductn timezone:vietnam

# Đồng bộ giờ từ NTP server mặc định vn.pool.ntp.org
./ductn time:sync

# Set timezone Việt Nam rồi đồng bộ giờ
./ductn time:init
```

Ghi chú vận hành:

- Linux ưu tiên `timedatectl`; nếu không có sẽ fallback sang cập nhật `/etc/localtime`.
- macOS dùng `systemsetup` cho timezone và `date` cho giờ hệ thống.
- Windows map timezone Việt Nam sang `SE Asia Standard Time` qua `tzutil` và dùng PowerShell `Set-Date` khi sync giờ.
- Các command set timezone/giờ thường cần quyền root/admin hoặc `sudo`.
- NTP sync dùng UDP port 123; môi trường bị chặn network/firewall có thể timeout.
- `src/debian/postinst` cố gọi `ductn time:timezone` trong bước `configure` để chuẩn hóa timezone sau khi cài package; lỗi ở bước này không làm fail install.

## Legacy Bash

Các Bash script cũ nằm ở `src/var/lib/`. Đây là nguồn chức năng ban đầu của dự án và vẫn còn nhiều phần chưa migrate.

Một số nhóm Bash legacy còn tồn tại trong `src/var/lib/` vì chưa có Python module tương ứng hoặc vẫn là bootstrap/helper shell:

- `completion.sh`, `functions.sh`, `main.sh`, `help.sh`
- `curl.sh`, `git.sh`, `ip.sh`, `os.sh`, `sys.sh`, `sys.service.valid.sh`, `wg.sh`
- `mssql.sh`
- `environment.sh`, `environment.color.sh`, `environment.text.sh`
- `php.sh`, `php.lar.sh`, `php.m2.sh`

Các Bash đã có Python module tương ứng được chuyển sang `deprecated/src/var/lib/`, gồm `apt.sh`, `dns.sh`, `swap.sh`, `ssh.sh`, `cronjob.sh`, `disk.sh`, `file.sh`, `gpg.sh`, `host.sh`, `httpd.sh`, `log.sh`, `port.sh`, `route.sh`, `server.sh`, `service.sh`, `ufw.sh`, `user.sh`, `vm.sh`. Các nhóm `httpd:*`, `dns:technitium:*`, `ufw:*` đã bị gỡ khỏi command surface active; Bash/Python implementation tương ứng nằm trong `deprecated/`.

macOS-specific scripts vẫn nằm trong `src/var/lib/macos/` cho tới khi có migration riêng.

Khi migrate, không xóa Bash cũ ngay nếu chưa chắc command Python tương đương đã đủ hành vi. Nên chuyển sang `deprecated/` sau khi đã test và cập nhật `TASKS.md`.

## Migration Bash sang Python

Mục tiêu migration:

1. Chuyển từng nhóm Bash command thành module Python trong `src/utils/`.
2. Giữ tương thích tên command CLI hiện có nếu có người dùng đang phụ thuộc.
3. Hỗ trợ Linux và macOS rõ ràng trong từng module.
4. Ghi rõ command nào đã migrate, command nào pending trong `TASKS.md`.
5. Chỉ deprecate Bash script sau khi bản Python đã chạy ổn.

Quy trình đề xuất cho mỗi nhóm command:

1. Đọc Bash script trong `src/var/lib/<name>.sh`.
2. Liệt kê command/function public cần giữ.
3. Tạo hoặc cập nhật `src/utils/<name>.py`.
4. Đăng ký command bằng `@register_command`.
5. Cập nhật import trong `src/utils/__init__.py`.
6. Test command trên môi trường phù hợp.
7. Cập nhật `TASKS.md` và README nếu command mới quan trọng.
8. Chuyển Bash script sang `deprecated/` khi đủ điều kiện.

## Build Debian package

Metadata Debian nằm trong `src/debian/`:

- `src/debian/control`: danh sách package và dependencies.
- `src/debian/changelog`: version/release history.
- `src/debian/*.install`: mapping file vào từng binary package.
- `src/debian/rules`: rule build package.

Script build chính:

```bash
cd src
./build.sh
```

Không tự ý sửa các file packaging nhạy cảm nếu không có yêu cầu rõ ràng:

- `src/debian/control`
- `src/debian/changelog`
- `.github/workflows/build.yml`

## Dependencies

Python dependencies nằm trong `src/requirements.txt`:

- `distro`
- `requests`
- `rich`
- `argcomplete`
- `psutil`
- `netifaces`
- `ipaddress`
- Pin riêng cho macOS cũ: `urllib3<2`, `requests<2.28`

System dependencies chính được khai báo trong `src/debian/control`, gồm `net-tools`, `jq`, `curl`, `bash-completion`, `openssl`, `unzip`, `apt-transport-https`, `sudo`, `dnsutils`, `lsof`, `shpool` và Python build dependencies.

## Development rules

- Không làm trực tiếp trên `main` khi có code change lớn.
- Mỗi task nên có branch riêng.
- Không push/PR/merge khi chưa được phép.
- Không commit secrets, `.env`, token hoặc API key.
- Không sửa production config nếu không có yêu cầu rõ.
- Mọi module mới hoặc thay đổi hành vi quan trọng cần cập nhật tài liệu.

## Troubleshooting

### `rg: command not found`

Môi trường dev có thể thiếu `ripgrep`. Dùng tạm:

```bash
find . -type f
```

hoặc cài `ripgrep` trong môi trường dev nếu được phép.

### Import Python lỗi ghi log `/var/log/ductnd`

Khi chạy bằng root trong môi trường read-only/sandbox, import `src/utils/__init__.py` có thể lỗi vì không ghi được `/var/log/ductnd/ductnd.log`.

Cách xử lý:

- Chạy trong môi trường có quyền ghi `/var/log/ductnd`.
- Hoặc chỉnh logging để fallback stdout khi không ghi được log file trong task riêng.

### Command Python chưa đủ so với Bash cũ

Kiểm tra `TASKS.md` và Bash script tương ứng trong `src/var/lib/`. Nếu chưa migrate, chưa nên xóa Bash script.

## Tài liệu liên quan

- `TASKS.md`: backlog migration Bash sang Python.
- `AGENTS.md`: quy trình vận hành agent trong workspace.
- `SOUL.md`, `USER.md`, `IDENTITY.md`: context vận hành nội bộ.
- `deprecated/README.md`: ghi chú khu vực deprecated.

## License

[MIT](./LICENSE)
