# 5.8.7 — Salvage & cleanup 13 file bash chết

**Ngày:** 2026-11-26
**Nhánh:** `chore/5.8.7-cleanup-dead-bash`
**Trước:** `src/var/lib/` còn 17 file bash (1 591 dòng), **không file nào được đóng gói** vào `.deb`.
**Sau:** `src/var/lib/` rỗng. Command tăng 87 → 128.

Tài liệu này ghi lại **từng phần được giữ lại** khi xoá 13 file bash "chết", và
những gì **cố ý bỏ**. Quy tắc: phần nào Python đã có → xoá; phần nào chưa có và
còn giá trị → port sang Python rồi mới xoá.

---

## Bảng tổng hợp

| File bash | Dòng | Xử lý | Command Python |
|-----------|------|-------|----------------|
| `git.sh` | 218 | **Salvage + sửa 5 lỗi ngữ nghĩa** | `git:*` |
| `main.sh` | 195 | Salvage nửa inventory | `fleet:status` |
| `environment.color.sh` | 181 | Salvage palette | module `style.py` |
| `mssql.sh` | 230 | Salvage toàn bộ, viết lại repo setup | `sqlsrv:*`, `mssql:*` |
| `macos/wg.sh` | 186 | Salvage phần an toàn | `wg:*` |
| `macos/sshfs.sh` | 85 | Salvage, bỏ hardcode | `sshfs:*` |
| `os.sh` | 80 | Sửa lỗi `distro` trên macOS | `os:*` |
| `completion.sh` | 78 | Salvage 6 function → 2 command | `completion:path`, `completion:exists` |
| `help.sh` | 61 | Không cần — đã có | — |
| `php.sh` | 60 | Salvage verify SHA384 | `php:*` |
| `macos/os.sh` | 57 | Salvage `sw_vers` | `os:*` |
| `macos/dns.sh` | 58 | Salvage | `dns:set`, `dns:status` |
| `functions.sh` | 33 | Salvage | `hash:md5`, `ssh` |
| `curl.sh` | 32 | Không cần — đã có | — |
| `environment.text.sh` | 14 | Salvage 3 glyph | `style.py` |
| `environment.sh` | 13 | Không cần | — |
| `wg.sh` | 10 | Không cần (chỉ shim) | — |
| `ductnd.sh.org` | 38 | Không cần (loader cũ) | — |

---

## 1. `git.sh` — 5 lỗi ngữ nghĩa được sửa

Đây là phát hiện quan trọng nhất: Python **không chỉ thiếu**, mà làm **sai** so với bash.

| Command | Bash (đúng) | Python trước 5.8.7 (sai) | Nay |
|---------|-------------|--------------------------|-----|
| `git:detrack` | `update-index --no-assume-unchanged` | `git rm --cached` — **xoá file khỏi index** | `update-index --no-assume-unchanged` |
| `git:untrack` | `update-index --assume-unchanged` | alias sang detrack | `update-index --assume-unchanged` |
| `git:viewuntrack` | `git ls-files -v \| grep '^[[:lower:]]'` | `git status --short` lọc `??` | parse `ls-files -v` |
| `git:tag:cleanup N` | xoá N tag đầu, xoá phần còn lại trên origin | chỉ **in** danh sách, không xoá | xoá + `fetch --prune` |
| `git:configure --global` | thêm `core.fileMode`, `core.autocrlf`, `core.eol`, `gc.auto`, `receive.denyCurrentBranch`, sinh `~/.gitignore` | **thiếu hết** | đầy đủ |

`git rm --cached` khác hoàn toàn `update-index --assume-unchanged`:
lệnh đầu **xoá file khỏi index** (lần commit sau file biến mất khỏi repo),
lệnh sau chỉ đánh dấu để git bỏ qua thay đổi. Ai chạy `ductn git:detrack`
trước 5.8.7 có thể đã vô tình xoá file khỏi repo.

Template `~/.gitignore` (khoảng 100 dòng: Node, Go, GitBook, IntelliJ) được
giữ nguyên nội dung trong `GITIGNORE_TEMPLATE`.

---

## 2. `disk.sh` — ZFS replace (ví dụ Sếp nêu)

`disk.sh` đã ở `deprecated/`, nhưng **bốn khối chưa từng có bản Python**:

| Bash | Nội dung | Python trước | Nay |
|------|----------|--------------|-----|
| `sys:disk:check8k` | `dd bs=8k count=10k` (80 MB) | gọi `smartctl` — **sai mục đích** | `disk:check` chạy `dd` |
| `sys:disk:check512k` | `dd bs=512k count=1k` (512 MB) | như trên | `disk:check --sector-size 512k` |
| `zfs:disk:replace_disk` | `zpool replace -f pool old new` | **không có** | `zfs:disk:replace:disk` |
| `zfs:disk:replace_boot_disk` | comment `sgdisk -R`, `sgdisk -G`, `zpool replace` | **không có** | `zfs:disk:replace:boot` |
| `zfs:disk:format_boot_disk` | comment `proxmox-boot-tool format` | chỉ in cảnh báo | `zfs:disk:format:boot:disk` chạy thật |

### Thay đĩa hỏng trong pool RAIDZ

```bash
# 1. Xem topology hiện tại
ductn zfs:disk:list

# 2. Đưa đĩa hỏng ra khỏi pool (nếu zpool chưa tự fault)
ductn zfs:disk:offline rpool ata-HITACHI_HUA722010ALA330_J80TS2LL

# 3. Gắn đĩa mới, thay vào pool
ductn zfs:disk:replace:disk rpool \
  /dev/disk/by-id/ata-HITACHI_HUA722010ALA330_J80TS2LL-part3 \
  /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E-part3

# 4. Theo dõi resilver
watch -n5 'zpool status rpool'
```

### Thay đĩa BOOT của Proxmox

```bash
# 1. Cắm đĩa mới, xác định by-id path
ls -al /dev/disk/by-id/

# 2. Thay (ba bước sgdisk -R, sgdisk -G, zpool replace)
ductn zfs:disk:replace:boot \
  /dev/disk/by-id/ata-TOSHIBA_MQ01ABD100_48MFT0FZT \
  /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E

# 3. Format ESP trên phân vùng 2 của đĩa mới
ductn zfs:disk:format:boot:disk /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E-part2

# 4. Kiểm tra
proxmox-boot-tool status
zpool status rpool
```

Bản cũ `zfs:disk:replace_boot_disk` vẫn chạy nhưng chỉ gọi
`zpool replace <pool> <new_disk>` — **thiếu** `-part3` và thiếu `sgdisk`, nên
không dùng được cho đĩa boot thật. Nay nó delegate sang hàm mới kèm cảnh báo.

---

## 3. `environment.color.sh` + `environment.text.sh` → `style.py`

Bash định nghĩa ~50 biến màu ANSI và 3 ký hiệu trạng thái. Nay:

```python
from utils import style

print(style.ok("Wireguard installed"))    # [✓] Wireguard installed
print(style.fail("Wireguard not found"))  # [✗] Wireguard not found
print(style.info("Checking keys"))        # [i] Checking keys

print(style.c("bold text", style.B_GREEN))
```

Bảng 24-bit và 8-bit trong `environment.color.sh` là **comment tài liệu**
(khoảng 100 dòng), không phải code — không port.

Tự tắt màu khi không phải TTY hoặc có `NO_COLOR`/`DUCTN_NO_COLOR`.

---

## 4. `main.sh` → `fleet:status`

`_main()` có hai nửa:

**Nửa inventory (đã port):** duyệt domain, SSH đọc FQDN + version `ductn`,
cảnh báo host lệch bản.

```bash
ductn fleet:status web.diepxuan.corp db.diepxuan.corp
# hoặc
DUCTN_FLEET_DOMAINS=web.corp,db.corp ductn fleet:status
```

**Nửa WireGuard provisioning (không port):**

- hardcode dải `10.8.$serial.x` — `$serial` là Proxmox VMID, không còn nguồn
- ghi config bằng `sudo tee` qua SSH, không kiểm tra idempotent
- phụ thuộc `--host:serial`, `--host:is_server`, `--host:is_vpn_server` —
  tất cả đã bị bỏ cùng `host.sh`
- `wg set ... allowed-ips 0.0.0.0/0` trên client — route toàn bộ traffic mà
  không có kill-switch

Toàn bộ nhóm này thuộc môi trường đã deprecate cùng `env.sh`. Nếu cần lại,
nên làm bằng Ansible/Terraform chứ không nhét vào `ductn`.

---

## 5. `completion.sh` → 2 command

Bash có 6 function gần như trùng nhau. Nay gộp:

```bash
ductn completion:path magerun2   # /var/www/base/bash/completion/magerun2.sh
ductn completion:exists wp       # 1 hoặc 0
```

Giữ quirk `angular` → `angular2.sh` (bash cũng vậy).

`sys:completion:commands` (in danh sách command) đã có tương đương:
`ductn commands` / `completion:cache show`.

---

## 6. `mssql.sh` — 230 dòng, viết lại phần repo setup

Không port nguyên xi vì bash dùng `apt-key` (đã bị bỏ ở Debian 12 /
Ubuntu 24.04 — package hiện target `noble`) và hardcode Ubuntu 16.04–22.04.

| Khía cạnh | Bash | Python 5.8.7 |
|-----------|------|--------------|
| Repo key | `wget ... \| apt-key add -` | keyring `/etc/apt/keyrings/microsoft-prod.asc` + `signed-by` |
| Phiên bản Ubuntu | hardcode 16.04/18.04/20.04/22.04 | kiểm tra `VERSION_ID`, hỗ trợ 20.04/22.04/24.04 |
| Đường dẫn PHP | hardcode 7 phiên bản `mods-available` | đọc `php --ini` |
| `sqlsrv:ad:spn` | trộn PowerShell + `ktpass` + **mật khẩu domain trong argv** | **không port** → `docs/MSSQL-AD-SPN.md` |
| `sqlsrv:cron` | chỉ gọi `__sqlsrv:install`, chưa từng đăng ký | bỏ |

> **Cần làm:** bash gốc có mật khẩu literal `Ductn@7691` cho tài khoản
> `mssql`. Chuỗi này đã nằm trong git history. Phải đổi mật khẩu tài khoản.

---

## 7. `macos/wg.sh` — phần an toàn

Giữ: `wg:install`, `wg:config`, `wg:status`, `wg:log`, `wg:service:*`.

Bỏ hai hàm:

- **`wg:hotfix`** — sinh wrapper `/opt/homebrew/bin/wg-quick-bash5` chứa vòng
  `while true; do ductn dns:set 10.10.x.x; sleep 5; done` **không có điều kiện
  dừng**, hardcode DNS nội bộ diepxuan và tranh chấp với DHCP. Vấn đề nó vá
  (wg-quick reset DNS trên macOS) giải quyết bằng `WG_QUICK_DNS_SKIP=1` —
  chính file bash đó cũng đã tham chiếu biến này. Plist mới set biến đó.
- **`wg:fix`** — đổi tên network service bị mangle tiền tố `_`/space; là bản
  vá một lần cho một máy cụ thể.

---

## 8. `macos/sshfs.sh` — bỏ hardcode

Bash hardcode `root@web.diepxuan.corp:/var/www/laravel` →
`/Users/ductn/Developer/laravel` và `IdentityFile=/Users/ductn/.ssh/id_rsa`.
Nay lấy từ tham số:

```bash
ductn sshfs:service:install root@web.diepxuan.corp:/var/www/laravel \
  /Users/ductn/Developer/laravel
```

SSH key từ `$DUCTN_SSHFS_IDENTITY`, mặc định `~/.ssh/id_rsa`.

---

## 9. `os.sh` + `macos/os.sh` — sửa lỗi thật trên macOS

Module `distro` đọc `/etc/os-release` — file **không tồn tại trên macOS**, nên
`os:codename`/`os:release`/`os:distro` trả rỗng. Bash có bản `macos/os.sh`
dùng `sw_vers`; Python chưa bao giờ port phần đó.

Nay `system_os.py` tự nhánh theo `sys.platform == "darwin"`:

| Command | macOS | Linux |
|---------|-------|-------|
| `os:codename` | `sw_vers -productVersion` → `15.1` | `distro.codename()` |
| `os:release` | `sw_vers -buildVersion` → `24B83` | `distro.version()` |
| `os:distro` | `sw_vers -ProductName` → `macOS` | `distro.id()` |

---

## 10. `php.sh` — verify SHA384

Bash tải `getcomposer.org/installer` rồi so SHA384 với
`composer.github.io/installer.sig` **trước khi chạy**. Python có comment
`# Verify signature (skip for now)` — tức là chạy installer chưa kiểm tra.

Nay verify thật, và tải vào `tempfile.mkdtemp()` thay vì thư mục home.

---

## 11. `functions.sh` → `hash:md5` + `ssh`

| Bash | Python | Ghi chú |
|------|--------|---------|
| `--hash_MD5` | `hash:md5` | dùng `secrets` 20 ký tự thay `$RANDOM \| md5sum` |
| `--ssh host cmd` | `ssh host cmd` | giữ `-T`; bash nuốt stderr, Python log warning |
| `--echo` | `echo` | đã có |
| `--logger` | `logging` | không cần command |
| `--do_no_thing` | — | không cần |
| `---v` | `version` | đã có |

---

## 12. `macos/dns.sh` → `dns:set` + `dns:status`

Bash chỉ có trên macOS và `dns:status` gọi `dig status` — **sai cú pháp**,
`dig` không có subcommand `status`. Nay đọc
`networksetup -getdnsservers <service>` cho từng service.

`dns:set` giữ logic lọc IP sống bằng ping trước khi đặt.

Cả hai báo lỗi rõ nếu chạy trên Linux (nơi phải sửa `/etc/resolv.conf` hoặc
netplan).

---

## 13. Ba file không cần salvage

| File | Lý do |
|------|-------|
| `help.sh` | `about.py` đã có `version`, `version:newrelease`, `help` |
| `curl.sh` | `curl_utils.py` đã có `curl:get`, `curl:gg` |
| `environment.sh` | chỉ set `EUID`/`SUDO` và shim `--isenabled` |
| `wg.sh` | chỉ có shim `--isenabled`, không logic |
| `ductnd.sh.org` | loader bash cũ (source `*.sh` từ `/var/lib/ductn`), đã bị `src/ductn.py` thay |

---

## 14. Hai lỗi phát hiện thêm khi smoke test

Không thuộc 17 file bash, nhưng lộ ra khi chạy thử toàn bộ 128 command sau
khi salvage (mỗi command có timeout 3 giây, chặn thay đổi hệ thống).

### `interface:service` crash trên Linux

```python
def get_active_service():
    iface = subprocess.check_output(["route", "get", "default"], text=True)
```

`route get default` là cú pháp macOS. Trên Linux `route` là lệnh khác hẳn và
trả exit 3, nên `CalledProcessError` nổi lên tận CLI. Hàm còn gọi
`networksetup` (chỉ có trên macOS) mà không kiểm tra nền tảng.

Nay `get_active_service()` chỉ dùng `networksetup` khi
`sys.platform == "darwin"`; Linux trả interface mặc định từ
`ip route show default`. Cả `get_default_interface()` cũng bắt
`FileNotFoundError`/`CalledProcessError` thay vì để nổi lên.

Test: `tests/unit/test_interface.py` (13).

### `dns:set` không có chế độ reset

Bash `d_dns:set` chạy được **không tham số**: `VALID_DNS=${VALID_DNS:-"Empty"}`
nghĩa là reset DNS về DHCP. Điều này cần thiết vì `wg:service:stop` gọi đúng
như vậy — nếu không reset, DNS còn trỏ vào resolver của tunnel đã tắt và máy
mất phân giải tên.

Bản Python đầu tiên của em từ chối chạy khi không có tham số, làm hỏng
đường thoát đó. Nay `dns:set` không tham số = reset, và
`d_wg_service_stop()` gọi `d_dns_set()` sau `launchctl bootout`, đúng bash.

---

## Kiểm chứng

```bash
# 1. Không còn file bash nào trong src/var/lib/
ls -A src/var/lib/          # rỗng

# 2. Số command
python3 -c "import sys; sys.path.insert(0,'src'); from utils.registry import COMMANDS; print(len(COMMANDS))"
# 128

# 3. Test suite
python3 -m unittest discover tests/unit
# Ran 343 tests — OK

# 4. Không còn tham chiếu tới file đã xoá
grep -rn "var/lib/\(git\|php\|curl\|completion\|main\|help\|mssql\|os\)\.sh" src/ tests/ --include="*.py"
# (rỗng)
```

Test mới: `test_style.py` (16), `test_helpers.py` (13), `test_git_utils.py` (24),
`test_mssql.py` (26), `test_salvage.py` (33), `test_macos_salvage.py` (27),
`test_interface.py` (13), `test_disk.py` viết lại (23).
Tổng +161 test (182 → 343).
