# BOOTSTRAP.md — DiepXuan Personal Package

## 1. Overview

| Key | Value |
|-----|-------|
| **Project** | ductnd (DiepXuan Personal Package) |
| **Remote** | `https://github.com/diepxuan/management.git` |
| **Package source** | `diepxuan` |
| **Binary packages** | `ductn`, `lar`, `m2`, `ductn-ll` |
| **Maintainer** | Tran Ngoc Duc <ductn@diepxuan.com> |
| **PPA** | https://ppa.diepxuan.com |
| **Workspace** | `/root/.openclaw/workspace/projects/ductnd/` |

## 2. Trạng thái

- **CLI mới:** Python, entrypoint `src/ductn.py` và các module `src/utils/`.
- **CLI cũ (legacy):** Bash scripts trong `src/var/lib/`. Nhiều chức năng Bash chưa migrate sang Python.
- **Migration tracking:** `TASKS.md`.
- **Phiên bản gần nhất:** xem `src/debian/changelog`.

## 3. Tech stack

- Python 3.x (`src/ductn.py`, `src/utils/`)
- Bash (`src/var/lib/`, `src/ductn.sh`)
- Debian packaging (`src/debian/`)
- PowerShell Windows task đã deprecated tại `deprecated/task/`
- Laravel/Magento wrapper binaries (`lar/`, `m2/`); Laravel App build commands cũ trong `app/Console/Commands/App/` đã được xóa khỏi source chính.

## 4. Cấu trúc thư mục chính

```text
.
├── src/
│   ├── ductn.py              # Python CLI entrypoint
│   ├── ductn.sh              # Shell wrapper
│   ├── requirements.txt      # Python dependencies
│   ├── utils/                # Python command modules (Python mới)
│   ├── var/lib/              # Legacy Bash command library
│   └── debian/               # Debian packaging metadata
├── ci/                       # Build/publish scripts
├── deprecated/               # Mã/config cũ đã tách
│   └── task/                 # PowerShell scripts Windows đã deprecated
├── .github/workflows/        # CI build workflow
├── README.md                 # Tài liệu tổng quan
├── TASKS.md                  # Backlog migration Bash → Python
├── BOOTSTRAP.md              # File này — project primer
├── SOUL.md / USER.md / IDENTITY.md / AGENTS.md
└── memory/                   # Daily session notes
```

## 5. Python CLI

- **Entry point:** `PYTHONPATH=src python3 src/ductn.py`
- **Command registry:** `src/utils/registry.py` — decorator `@register_command`.
- **Quy ước đặt tên:** `d_dns_clean` → command `dns:clean`.
- **Liệt kê command:** `d_commands`.
- **Module mới:** đặt trong `src/utils/`, import tại `src/utils/__init__.py`.

### Command groups hiện có

| Nhóm | Commands chính |
|------|----------------|
| About | `d_help`, `d_version`, `d_version_newrelease` |
| Network/IP | `d_ip_local`, `d_ip_locals`, `d_ip_wan` |
| DNS | `d_dns_clean`, `d_dns_reset`, `d_dns_disable`, `d_dns_resolved`, `d_dns_watch` |
| APT | `d_apt_fix`, `d_apt_check` |
| Host | `d_host_name`, `d_host_domain`, `d_host_fullname` |
| OS | `d_os_codename`, `d_os_release`, `d_os_distro`, `d_os_architecture`, `d_os_type` |
| System | `d_sys_update`, `d_update`, `d_sys_info` |
| Service | `d_service_install`, `d_service_start`, `d_service_stop`, `d_service_restart`, `d_service_status`, `d_service_watch` |
| Route | `d_route_default`, `d_route_monitor` |
| VM/WG | `d_vm_info`, `d_vm_sync`, `d_wg_stop` |
| File/Env | `d_file_cleanpath`, `d_env_detect`, `d_alias_ll` |

## 6. Bash legacy

Các Bash script cũ trong `src/var/lib/` vẫn còn nhiều module chưa migrate.

Không xóa Bash cũ khi chưa chắc command Python tương đương đã đủ hành vi. Chuyển sang `deprecated/` khi đủ điều kiện và cập nhật `TASKS.md`.

## 7. Build Debian package

- **Build script:** `cd src && ./build.sh`
- **Metadata:** `src/debian/control`, `src/debian/changelog`, `src/debian/rules`, `src/debian/*.install`
- **Hạn chế sửa:** `src/debian/control`, `src/debian/changelog`, `.github/workflows/build.yml` khi không được yêu cầu rõ.

## 8. Dependencies

- **Python:** xem `src/requirements.txt` — `distro`, `requests`, `rich`, `argcomplete`, `psutil`, `netifaces`.
- **System:** xem `src/debian/control` — `net-tools`, `jq`, `curl`, `bash-completion`, `openssl`, `dnsutils`, `lsof`, v.v.
- **Log path:** `/var/log/ductnd/ductnd.log` — có thể lỗi trong sandbox read-only.

## 9. Agent identity

- **Tên agent:** Bột
- **Xưng hô:** em / Sếp / đệ (sub-agent)
- **Ngôn ngữ:** tiếng Việt, không emoji
- **Quy trình:** đọc SOUL.md → USER.md → IDENTITY.md → memory/YYYY-MM-DD.md
- **Rules:** không push/PR/merge khi chưa được phép; không sửa production config khi không được yêu cầu; mỗi task = 1 branch = 1 PR.

## 10. Tài liệu liên quan

| File | Mục đích |
|------|----------|
| `README.md` | Tài liệu tổng quan và migration guide |
| `TASKS.md` | Backlog migration Bash → Python |
| `SOUL.md` | Nguyên tắc vận hành agent |
| `USER.md` | Thông tin và working style của Sếp |
| `IDENTITY.md` | Danh tính và vai trò agent |
| `AGENTS.md` | Quy trình workspace |
| `docs/UPDATE-YYYY-MM-DD.md` | Ghi chú thay đổi config/behavior quan trọng |
