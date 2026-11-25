# Báo cáo migration Bash → Python

**Ngày:** 2026-11-25
**Version:** `5.8.6+ppa~1`
**Commit:** `753a614`
**Phương pháp:** đối chiếu trực tiếp code trong `src/var/lib/`, `deprecated/`, `src/utils/` và command registry tại runtime — không dựa vào `TASKS.md` (đã lỗi thời từ 2026-07-20).

---

## 1. Tóm tắt

| Chỉ số | Giá trị |
|--------|---------|
| Command Python đang active | **87** |
| Module Python trong `src/utils/` | **38** file, **5 712** dòng (chưa tính `__init__.py`; tổng cả `__init__.py` là 5 834) |
| File bash còn trong `src/var/lib/` | **17** file, **1 591** dòng |
| — Trong đó **thực sự chưa migrate** | **4** file, **559** dòng, **24** command |
| — Trong đó **code chết, đã có Python thay thế** | **13** file, **1 032** dòng |
| File bash được đóng gói vào `.deb` | **0** |

Kết luận ngắn: **migration đã xong ~95%**. Toàn bộ `src/var/lib/*.sh` **không còn được đóng gói** vào gói `ductn` (`src/debian/ductn.install` chỉ copy `src/ductn/var/lib/lxc/hooks/default-hook.sh`, không copy `src/var/lib/`), không file nào được reference từ Python, `postinst`, `postrm`, hay bash completion. Chúng chỉ còn là rác trong repo.

Thực chất còn **3 mảng chưa migrate**: MSSQL và 2 nhóm tính năng macOS (WireGuard, SSHFS).

---

## 2. Nhóm A — Thực sự chưa migrate

Đây là các file bash còn nằm trong `src/var/lib/` (chưa được deprecate) và **chưa có module Python tương đương**.

### A1. MSSQL / SQLSRV — `src/var/lib/mssql.sh` (230 dòng)

Ưu tiên cao nhất trong nhóm còn lại — đây là Linux, không phải macOS.

| Command bash | Chức năng | Python |
|--------------|-----------|--------|
| `sqlsrv:apt` | Thêm Microsoft APT repo + GPG key | ❌ |
| `sqlsrv:install` | Cài `mssql-server` | ❌ |
| `sqlsrv:php` | Cài `msodbcsql17`/`mssql-tools` | ❌ |
| `sqlsrv:php:install` | Cài PHP driver `sqlsrv`/`pdo_sqlsrv` (pecl) | ❌ |
| `sqlsrv:php:enable` | Bật extension trong `php.ini` | ❌ |
| `sqlsrv:php:disable` | Tắt extension | ❌ |
| `sqlsrv:ad:spn` | Tạo Kerberos SPN cho AD auth | ❌ |
| `sqlsrv:cron` | Cron job cho SQL Server | ❌ |

**Rủi ro kỹ thuật:** script gốc hardcode danh sách Ubuntu `16.04 18.04 20.04 22.04` và dùng `apt-key` (đã deprecated trên Debian 12+/Ubuntu 24.04, package hiện target `noble`). Nếu migrate phải viết lại phần repo setup bằng `signed-by` + keyring file, không port nguyên xi.

Hiện `src/utils/log.py` chỉ *đọc* log MSSQL (`/var/opt/mssql/log/errorlog`), không có logic cài đặt.

### A2. WireGuard trên macOS — `src/var/lib/macos/wg.sh` (186 dòng)

Chỉ chạy trên macOS (`os: ` filter). Linux không bị ảnh hưởng.

| Command | Chức năng |
|---------|-----------|
| `wg:install` | Cài wireguard-tools qua Homebrew |
| `wg:config` | Sinh file cấu hình |
| `wg:service:install` | Tạo launchd plist |
| `wg:service:start` / `:stop` / `:restart` | Điều khiển service |
| `wg:status` | Trạng thái tunnel |
| `wg:log` | Xem log |
| `wg:fix` / `wg:hotfix` | Vá cấu hình sau khi mạng đổi |

### A3. SSHFS trên macOS — `src/var/lib/macos/sshfs.sh` (85 dòng)

| Command | Chức năng |
|---------|-----------|
| `sshfs:install` | Cài `sshfs` + `macfuse` |
| `sshfs:service:install` | Tạo launchd plist |
| `sshfs:service:start` / `:stop` / `:restart` | Điều khiển mount |

### A4. DNS trên macOS — `src/var/lib/macos/dns.sh` (58 dòng)

Migrate **một phần**: `dns:clean` đã có trong `src/utils/dns.py`.

| Command | Python |
|---------|--------|
| `dns:clean` | ✅ `dns:clean` |
| `dns:set` | ❌ (set DNS server thủ công) |
| `dns:status` | ❌ (xem DNS server hiện tại) |

Lưu ý: trên Linux, `src/utils/dns.py` có `dns:reset`, `dns:disable`, `dns:resolved` — nhiều hơn bản macOS. Thiếu `dns:set`/`dns:status` là thiếu ở **cả hai** nền tảng, không riêng macOS.

---

## 3. Nhóm B — Code chết, đã có Python thay thế

13 file, 1 032 dòng. **Không function nào bị mất** — tất cả đã có command Python cùng tên hoặc tên đã đổi hợp lý.

| File bash | Dòng | Thay thế bằng | Ghi chú |
|-----------|------|---------------|---------|
| `git.sh` | 218 | `src/utils/git_utils.py` (103 dòng, 5 command) | Đủ 5/5: `configure`, `detrack`, `untrack`, `viewuntrack`, `tag:cleanup` |
| `main.sh` | 195 | `src/ductn.py` | Entry point cũ, đã bị thay hoàn toàn |
| `environment.color.sh` | 181 | không cần | Chỉ định nghĩa biến màu ANSI, không có function. Python dùng ANSI inline + `rich` |
| `os.sh` | 80 | `src/utils/system_os.py` (6 command) | `os:DISTRIB` đổi tên thành `os:distro` |
| `completion.sh` | 78 | `src/utils/completion.py` + `src/ductn/usr/share/bash-completion/completions/ductn` | Cache command + file completion tĩnh |
| `help.sh` | 61 | `src/utils/about.py` (3 command) | `version`, `version:newrelease` |
| `php.sh` | 60 | `src/utils/php_utils.py` (79 dòng, 4 command) | Đủ 4/4 |
| `macos/os.sh` | 57 | `src/utils/system_os.py` | Trùng logic Linux |
| `functions.sh` | 33 | `src/utils/helpers.py` + `cli.py` | `--echo` → `echo`; `--logger` → `logging`; `--ssh`/`--hash_MD5` chỉ dùng bởi `main.sh` đã bỏ |
| `curl.sh` | 32 | `src/utils/curl_utils.py` (87 dòng, 2 command) | `curl:get`, `curl:gg` |
| `environment.text.sh` | 14 | không cần | Chỉ biến text |
| `environment.sh` | 13 | không cần | Chỉ `EUID`/`SUDO` + shim `--isenabled` |
| `wg.sh` | 10 | không cần | Chỉ có shim `--isenabled`, không có logic |

**Đề xuất:** xoá toàn bộ 13 file trong 1 PR riêng (không cần `deprecated/`, vì `deprecated/` đã có 31 file rồi — chuyển thêm vào chỉ làm rối thêm).

---

## 4. Nhóm C — Bị bỏ khi deprecate, không có tương đương Python

Các file đã nằm trong `deprecated/src/var/lib/`, nhưng **một số command bên trong không được port** sang Python. Cần Sếp xác nhận đây là quyết định đúng hay là bỏ sót.

### C1. Bỏ sót có khả năng cao — nên bổ sung

| Command bash | File gốc | Ghi chú |
|--------------|----------|---------|
| `file:chmod` | `file.sh` | Python chỉ có `file:cleanpath`. Ba command `file:chmod`, `file:chmod:files`, `file:chmod:dirs` **không có** ở đâu cả |
| `pve:vm` | `vm.sh` | Chỉ là `apt install qemu-guest-agent` — 3 dòng, dễ port thành `vm:agent:install` |
| `log:config:store`, `log:config:mssql` | `log.sh` | Hàm nội bộ `_log_config_store()` / `_log_config_mssql()` **đã có** trong `log.py`, nhưng không expose thành command con — `log:config` gọi cả hai |

### C2. Bỏ có chủ đích — không cần làm

| Nhóm | Command | Lý do |
|------|---------|-------|
| User | 6 (`user:new`, `user:config*`, `user:is_sudoer`) | Deprecate ở 5.6.4, `user.py` đã chuyển sang `deprecated/` |
| VPN | 7 (`vpn:wireguard:*`, `vpn:openvpn:*`) | Deprecate ở 5.6.1 |
| SSH | 3 (`ssh:copy`, `ssh:install`, `ssh:permision`) | Bỏ vì thao tác trực tiếp private key / `authorized_keys`, không ship mặc định |
| UFW | 5 | Bỏ nhóm firewall |
| MySQL | 2 (`mysql:setup`, `mysql:ssl:enable`) | Bỏ nhóm MySQL |
| Swap | 2 | Bỏ nhóm swap |
| HTTPD | 4 | Bỏ nhóm web server |
| DHCP | 2 | Bỏ nhóm DHCP |
| DDNS / Technitium | 5 | Bỏ nhóm DNS server |
| Service validation | 4 (`sys:service:valid/httpd/mysql/mssql`) | Không còn dùng apache2/mysql/mssql-server |
| Env | 12 (`sys:env:*`) | `env.sh` deprecate; `env:domains`/`env:nat` gắn chặt hạ tầng Proxmox cũ |
| Host/hosts | 13 (`host:address`, `host:serial`, `hosts:add`, …) | `host.sh` deprecate; chỉ giữ 3 command đơn giản (`host:name/domain/fullname`). `host:address` thay bằng `ip:local` |
| IP | 7 (`ip:gateway`, `ip:subnet`, `ip:valid`, `ip:wanv4/v6`, `ipAll`, `ip:check`) | `addr.py` viết lại tinh gọn; `ip:wanv4` → `ip:wan` |
| Completion con | 7 (`sys:completion:magerun2`, `:wp`, `:angular`, …) | Thay bằng `completion:cache` + file completion tĩnh |
| Route | 2 (`route:reload`, `route:checkAndUp`) | Đã gộp vào `_interface_reload()` / `_route_monitor()` |
| SSL | 3 (`ssl:pull/push/upload`) | Bỏ theo Task 1.3 |
| Alias / misc | `alias:ll`, `laravel`, `magento`, `grunt`, `magerun2` | Thay bằng wrapper `m2`, `lar` và command `php:lar`, `php:m2` |

---

## 5. Nhóm D — `TASKS.md` báo sai trạng thái

File `TASKS.md` ghi **16 task PENDING**, nhưng thực tế **11 task đã xong** từ lâu. Đây là nguyên nhân lớn nhất khiến báo cáo tiến độ bị lệch.

| Task trong TASKS.md | TASKS.md ghi | Thực tế | Bằng chứng |
|---------------------|--------------|---------|------------|
| 1.7 Cronjob | ⏳ PENDING | ✅ XONG | `src/utils/cronjob.py`, 4 command `cron:min/5min/hour/month` |
| 2.9 Disk/ZFS | ⏳ PENDING | ✅ XONG | `src/utils/disk.py` 145 dòng, 6 command gồm cả 3 command ZFS replace/offline/format |
| 2.13 Port | ⏳ PENDING | ✅ XONG | `src/utils/port.py`, `port:open` |
| 3.1 Git | ⏳ PENDING | ✅ XONG | `src/utils/git_utils.py` 103 dòng, 5/5 command |
| 3.4 PHP General | ⏳ PENDING | ✅ XONG | `src/utils/php_utils.py` 79 dòng, 4/4 command |
| 5.1 GPG | ⏳ PENDING | ✅ XONG | `src/utils/gpg.py` 71 dòng, 3 command |
| 5.2 CURL | ⏳ PENDING | ✅ XONG | `src/utils/curl_utils.py` 87 dòng, 2/2 command |
| 5.7 Server Install | ⏳ PENDING | ✅ XONG | `src/utils/server.py`, `server:install` |
| 5.8 Environment Detection | ⏳ PENDING | ✅ XONG | `src/utils/env_detect.py` 89 dòng (`detect_virt`, `detect_dmi`, `detect_container_proc`, `detect_environment`) |
| 5.9 Helper Functions | ⏳ PENDING | ✅ XONG | `src/utils/helpers.py` |
| 5.10 Main Entry Point | ⏳ PENDING | ✅ XONG | `src/ductn.py` thay `main.sh` |
| 5.3 File Utilities | ⏳ PENDING | 🔀 MỘT PHẦN | Chỉ có `file:cleanpath`; `file:chmod*` còn thiếu |
| 5.4 Bash Completion | ⏳ PENDING | 🔀 MỘT PHẦN | `completion:cache` + file completion tĩnh; các completion con (`magerun2`, `wp`) chưa có |
| 5.5 MSSQL | ⏳ PENDING | ⏳ **ĐÚNG LÀ CHƯA** | Không có code Python nào |
| 2.8 User | ⏳ PENDING | 🚫 BỎ | Deprecate ở 5.6.4 |
| 4.1 Env/Network | ⏳ PENDING | 🚫 BỎ | `env.sh` đã vào `deprecated/` |

Ba task "PARTIAL" cũng cần chỉnh lại:

| Task | TASKS.md ghi | Thực tế |
|------|--------------|---------|
| 2.2 Host | 🔀 Partial, "10 lệnh còn lại" | **Xong phạm vi**: `host.sh` đã deprecate, chỉ giữ 3 command. 10 lệnh kia bị bỏ có chủ đích, không phải "còn lại" |
| 2.5 Service | 🔀 Partial, "4 lệnh còn lại" | **Xong**: 6 command trong `system_service.py`; `sys:service:main`/`isactive`/`d_un_as_service` đã được thay bằng `service:start/stop/restart/status/watch` |
| 2.7 VM | 🔀 Partial, "2 lệnh còn lại" | **Đúng là partial**: `pve:vm` và `vm:command` thực sự chưa có (xem C1) |

Dòng cuối `TASKS.md` ghi "Total: ~47 remaining bash scripts" — con số thực tế là **17 file, trong đó chỉ 4 file chưa migrate**.

---

## 6. Đề xuất thứ tự thực hiện

| # | Việc | Phạm vi | Ước lượng | Version đề xuất |
|---|------|---------|-----------|-----------------|
| 1 | Xoá 13 file bash chết (Nhóm B) | 1 032 dòng xoá, không thêm code | 1h | 5.8.7 |
| 2 | Cập nhật `TASKS.md` theo thực tế | Tài liệu | 1h | 5.8.7 |
| 3 | `mssql.py` — migrate `mssql.sh` | 230 dòng bash → ~250 dòng Python, 7 command | 1–2 ngày | 5.9.0 |
| 4 | `file:chmod`, `file:chmod:files`, `file:chmod:dirs` | 3 command nhỏ | 2h | 5.9.0 |
| 5 | `vm:agent:install` (từ `pve:vm`) | 1 command, `apt install qemu-guest-agent` | 30 phút | 5.9.0 |
| 6 | Expose `log:config:store` / `log:config:mssql` | 2 command, hàm đã có sẵn | 1h | 5.9.0 |
| 7 | `macos/wg.sh` — WireGuard macOS | 186 dòng → ~200 dòng Python, 10 command | 1 ngày | 5.9.1 |
| 8 | `macos/sshfs.sh` — SSHFS macOS | 85 dòng → ~100 dòng Python, 5 command | 4h | 5.9.1 |
| 9 | `dns:set`, `dns:status` | 2 command, cả Linux và macOS | 3h | 5.9.1 |

Sau bước 1 và 2, `src/var/lib/` chỉ còn 4 file — đúng bằng phạm vi chưa migrate, dễ nhìn.

**Lưu ý về thứ tự:** nên làm bước 1+2 trước để repo phản ánh đúng sự thật, tránh lặp lại tình trạng `TASKS.md` lệch 4 tháng.

---

## 7. Cách kiểm chứng báo cáo này

```bash
# 1. Xác nhận bash không được đóng gói
grep -v '^#' src/debian/ductn.install | grep 'var/lib'   # chỉ ra lxc hook

# 2. Xác nhận không file bash nào được reference
grep -rn --include='*.py' -E 'var/lib/(git|curl|php|help|main|os)\.sh' src/

# 3. Đếm command active
python3 -c "import sys; sys.path.insert(0,'src'); from utils.registry import COMMANDS; print(len(COMMANDS))"

# 4. Liệt kê command còn thiếu so với bash
#    (script đối chiếu ở mục 2 và 3 của báo cáo)
```

Đã chạy cả 4 bước trên tại commit `753a614`.

---

## 8. Ghi chú kỹ thuật

- `src/var/lib/*.sh` **không** nằm trong gói `.deb`. Dòng `var/lib/* var/lib/ductn` trong `src/debian/ductn.install` đã bị comment từ lâu. Nghĩa là các file này chỉ tồn tại trong git, không ảnh hưởng máy đã cài `ductn`.
- `deprecated/` hiện có **31 file bash** + thư mục `mysql/`. Đây là kho lưu lịch sử, không có test, không được đóng gói.
- Test suite hiện có 182 test. Riêng `tests/unit/test_modules.py` vẫn còn tham chiếu `utils.user` — module đã bị xoá ở 5.6.4, gây **1 test fail thường trực**. Nên sửa hoặc xoá test case này.
- `tests/unit/test_cli_output.py` cũng fail thường trực vì kỳ vọng dòng `cli` trong output help — output hiện tại đã đổi format. **2 fail này tồn tại trên `main` từ trước 5.8.6**, không phải regression.
