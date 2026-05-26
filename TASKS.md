# TASKS.md - Bash to Python Migration

**Project:** ductn (DiepXuan Personal Package)  
**Created:** 2026-04-18  
**Updated:** 2026-05-26  
**Goal:** Migrate all bash scripts from `src/var/lib/` to Python modules in `src/utils/`

---

## Migration Status

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Completed | 17 | Migrated to Python + deprecated bash |
| 🔄 In Progress | 0 | Currently being migrated |
| ⏳ Pending | 31 | Waiting to be migrated |
| 🔀 Partial | 8 | Partially migrated (some commands done, some pending) |
| 🚫 Deprecated | 3 | Bash scripts moved to deprecated/ |

---

## Phase 1: Core Infrastructure (HIGH PRIORITY)

### ✅ Task 1.1: APT Package Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/apt.sh` → deprecated
- **Python:** `src/utils/apt.py`
- **Commands:** `apt:fix`, `apt:check`, `apt:install`, `apt:remove`, `apt:uninstall`
- **PR:** #7 (merged)

### ✅ Task 1.2: DNS Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/dns.sh` → deprecated
- **Python:** `src/utils/dns.py`
- **Commands:** `dns:clean`, `dns:reset`, `dns:disable`, `dns:resolved`, `dns:watch`
- **PR:** #9, #10 (merged)

### ✅ Task 1.3: SSL Management
- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/ssl.sh` → `deprecated/src/var/lib/ssl.sh`
- **Python:** `src/utils/ssl.py`
- **Commands:**
  | Command | Description |
  |---------|-------------|
  | `ssl:install` | Install certbot plus Cloudflare/Apache/Nginx plugins |
  | `ssl:configure` | Configure default SSL certificates with auto Apache/Nginx integration or DNS fallback |
  | `ssl:setup` | Issue default or custom SSL certificates |
  | `ssl:certbot` | Run certbot with auto Apache/Nginx integration or Cloudflare DNS fallback |
- **Commands removed:** `ssl:pull`, `ssl:push`, `ssl:upload`
- **Tests:** `python3 -m unittest tests.unit.test_ssl -v`

### 🚫 Task 1.4: VPN/WireGuard Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/vpn.sh` → `deprecated/src/var/lib/vpn.sh`
- **Python:** `src/utils/vpn.py` → `deprecated/src/utils/vpn.py`
- **Commands removed:**
  - `vpn:wireguard:is_exist`
  - `vpn:wireguard:is:exist`
  - `vpn:wireguard:install`
  - `vpn:wireguard:keygen`
  - `vpn:wireguard:reload`
  - `vpn:wireguard:stop`
  - `vpn:wireguard:example`
  - `vpn:openvpn:uninstall`
  - `vpn:type`
- **Reason:** VPN command group removed from active Bash and Python CLI surface.

### ⏳ Task 1.5: SSH Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ssh.sh` (88 lines)
- **Python:** `src/utils/ssh.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `ssh:cleanup` | Clean SSH known_hosts |
  | `ssh:install` | Install/configure SSH server |
  | `ssh:permision` | Fix SSH permissions |
  | `ssh:copy` | Copy SSH keys |
- **Action:** Create `src/utils/ssh.py`

### ⏳ Task 1.6: Log Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/log.sh` (129 lines)
- **Python:** `src/utils/log.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `log` | Show ductn log |
  | `log:watch` | Watch log in realtime |
  | `log:cleanup` | Cleanup old logs |
  | `log:config` | Configure log rotation |
  | `log:config:store` | Store log config |
  | `log:config:mssql` | MSSQL log config |
- **Action:** Create `src/utils/log.py`

### ⏳ Task 1.7: Cronjob Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/cronjob.sh` (25 lines)
- **Python:** `src/utils/cronjob.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `cron:min` | Add minute cron job |
  | `cron:5min` | Add 5-minute cron job |
  | `cron:hour` | Add hourly cron job |
  | `cron:month` | Add monthly cron job |
- **Action:** Create `src/utils/cronjob.py`

---

## Phase 2: System Administration (MEDIUM PRIORITY)

### 🔀 Task 2.1: System Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/sys.sh` (99 lines)
- **Python:** `src/utils/system.py` (partially done: `d_sys_update`, `d_update`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `sys:init` | System initialization |
  | `sys:sysctl` | Apply sysctl config |
  | `sys:clean` | Clean system temp files |
  | `sys:upgrade` | System upgrade |
  | `sys:selfupdate` | Self-update ductn package |

### 🔀 Task 2.2: Host Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/host.sh` (117 lines)
- **Python:** `src/utils/host.py` (done: `d_host_name`, `d_host_domain`, `d_host_fullname`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `host:address` | Get host address |
  | `host:address:valid` | Validate host address |
  | `host:ip` | Get host IP |
  | `host:is_server` | Check if server |
  | `host:is_vpn_server` | Check if VPN server |
  | `host:serial` | Get hardware serial |
  | `hosts:add` | Add entry to /etc/hosts |
  | `hosts:remove` | Remove entry from /etc/hosts |
  | `hosts` | Show all hosts |
  | `sys:hosts:add/remove/domain/update` | System hosts management |

### 🔀 Task 2.3: IP Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/ip.sh` (148 lines)
- **Python:** `src/utils/addr.py` (done: `d_ip_local`, `d_ip_locals`, `d_ip_wan`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `ip:wanv4` | Get WAN IPv4 |
  | `ip:wanv6` | Get WAN IPv6 |
  | `ip:valid` | Validate IP |
  | `ipAll` | Show all IPs |
  | `ip:gateway` | Get gateway IP |
  | `ip:subnet` | Get subnet mask |
  | `ip:check` | Check IP connectivity |

### 🔀 Task 2.4: Route Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/route.sh` (118 lines)
- **Python:** `src/utils/route.py` (done: `d_route_default`, `d_route_monitor`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `route:checkAndUp` | Check and bring up route |
  | `route:reload` | Reload route config |

### 🔀 Task 2.5: Service Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/service.sh` (211 lines)
- **Python:** `src/utils/system_service.py` + `src/utils/service.py` (done: install/start/stop/restart/status/watch)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `sys:service:main` | Main service handler |
  | `sys:service:isactive` | Check if service active |
  | `sys:service:re-install` | Re-install service |
  | `d_run_as_service` | Run command as service |

### 🔀 Task 2.6: OS Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/os.sh` (80 lines)
- **Python:** `src/utils/system_os.py` (done: codename, release, distro, architecture, type)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `os:list` | List OS information |

### 🔀 Task 2.7: VM Management (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/vm.sh` (108 lines)
- **Python:** `src/utils/vm.py` (done: `d_vm_info`, `d_vm_sync`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `pve:vm` | Proxmox VM management |
  | `vm:command` | Run VM command |

### ⏳ Task 2.8: User Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/user.sh` (111 lines)
- **Python:** `src/utils/user.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `user:new` | Create new user |
  | `user:config` | Configure user |
  | `user:config:bash` | Setup user bash |
  | `user:config:chmod` | Fix user permissions |
  | `user:config:admin` | Make user admin |
  | `user:is_sudoer` | Check if user is sudoer |
- **Action:** Create `src/utils/user.py`

### ⏳ Task 2.9: Disk/ZFS Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/disk.sh` (60 lines)
- **Python:** `src/utils/disk.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `disk:check` | Check disk health |
  | `disk:check8k` | Check 8K sector disks |
  | `disk:check512k` | Check 512K sector disks |
  | `zfs:disk:list` | List ZFS disks |
  | `zfs:disk:offline` | Take ZFS disk offline |
  | `zfs:disk:replace` | Replace ZFS disk |
  | `zfs:disk:replace_disk` | Replace disk helper |
  | `zfs:disk:replace_boot_disk` | Replace boot disk |
  | `zfs:disk:format_boot_disk` | Format boot disk |
- **Action:** Create `src/utils/disk.py`

### ⏳ Task 2.10: UFW/Firewall Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ufw.sh` (54 lines)
- **Python:** `src/utils/ufw.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `ufw:disable` | Disable UFW |
  | `ufw:geoip:uninstall` | Remove GeoIP rules |
  | `ufw:geoip:allowCloudflare` | Allow Cloudflare IPs |
  | `ufw:fail2ban:uninstall` | Remove fail2ban |
  | `ufw:iptables:uninstall` | Remove iptables rules |
- **Action:** Create `src/utils/ufw.py`

### 🚫 Task 2.11: MySQL Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/mysql.sh` → `deprecated/src/var/lib/mysql.sh`
- **Python:** `src/utils/mysql_utils.py` → `deprecated/src/utils/mysql_utils.py`
- **Data/config:** `src/var/lib/mysql/` → `deprecated/src/var/lib/mysql/`
- **Commands removed:**
  - `mysql:setup`
  - `mysql:ssl:enable`
- **Reason:** MySQL command group removed from active Bash and Python CLI surface.

### ⏳ Task 2.12: Swap Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/swap.sh` (21 lines)
- **Python:** `src/utils/swap.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `swap:remove` | Remove swap |
  | `swap:install` | Create swap |
- **Action:** Create `src/utils/swap.py`

### ⏳ Task 2.13: Port Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/port.sh` (17 lines)
- **Python:** `src/utils/port.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `port:open` | Check if port is open |
- **Action:** Create `src/utils/port.py`

---

## Phase 3: Development Tools (MEDIUM PRIORITY)

### ⏳ Task 3.1: Git Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/git.sh` (218 lines)
- **Python:** `src/utils/git.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `git:configure` | Configure git for project |
  | `git:detrack` | Remove file from tracking |
  | `git:untrack` | Untrack file |
  | `git:viewuntrack` | View untracked files |
  | `git:tag:cleanup` | Cleanup old git tags |
- **Action:** Create `src/utils/git.py`

### 🔀 Task 3.2: PHP/Laravel (partial)
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/php.lar.sh` (22 lines)
- **Python:** `src/utils/` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `php:lar` | Laravel helper |
- **Action:** Create `src/utils/laravel.py`

### ⏳ Task 3.3: PHP/Magento2
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/php.m2.sh` (233 lines)
- **Python:** `src/utils/magento2.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `m2:ch` | Change permissions |
  | `m2:group` | Fix group permissions |
  | `m2:urn` | Generate URN |
  | `m2:perm` | Fix permissions |
  | `m2:rmgen` | Remove generated files |
  | `m2:static` | Deploy static content |
  | `m2:cache` | Manage cache |
  | `m2:index` | Reindex |
  | `m2:grunt` | Run grunt |
  | `m2:up` | Run upgrade |
  | `m2:config` | Show config |
  | `m2:setting` | Change settings |
  | `m2:developer` | Developer mode |
  | `m2:logenable/logdisable` | Toggle logging |
  | `m2:tempdebugenable/disable` | Toggle debug |
  | `m2:completion` | Bash completion |
- **Note:** `d_php:m2` exists but needs full migration
- **Action:** Create `src/utils/magento2.py`

### ⏳ Task 3.4: PHP General
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/php.sh` (60 lines)
- **Python:** `src/utils/php.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `php:composer:install` | Install composer |
  | `php:apt:install` | Install PHP via APT |
  | `php:install` | Install PHP |
  | `php:phpcsfixer:install` | Install PHP CS Fixer |
- **Action:** Create `src/utils/php_utils.py`

### ⏳ Task 3.5: HTTPD/Web Server
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/httpd.sh` (237 lines)
- **Python:** `src/utils/httpd.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `httpd:install` | Install web server |
  | `httpd:config` | Configure vhost |
  | `httpd:restart` | Restart web server |
  | `httpd:config:sites` | List configured sites |
- **Action:** Create `src/utils/httpd.py`

---

## Phase 4: Network & Security (LOWER PRIORITY)

### ⏳ Task 4.1: Environment/Network Config
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/env.sh` (199 lines)
- **Python:** `src/utils/env_config.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `env` | Show env config |
  | `env:domains` | Show domains |
  | `env:nat` | Show NAT config |
  | `env:dhcp` | Show DHCP config |
  | `env:vpn` | Show VPN config |
  | `env:sync` | Sync env config |
- **Action:** Create `src/utils/env_config.py`

### 🚫 Task 4.2: DDNS Management
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/ddns.sh` → `deprecated/src/var/lib/ddns.sh`
- **Python:** `src/utils/ddns.py` → `deprecated/src/utils/ddns.py`
- **Commands removed:**
  - `ddns:bind9:install`
  - `ddns:resolved`
- **Reason:** DDNS command group removed from active Bash and Python CLI surface.

### ⏳ Task 4.3: DNS Technitium
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/dns.technitium.sh` (32 lines)
- **Python:** `src/utils/dns_technitium.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `dns:technitium:install` | Install Technitium DNS |
  | `dns:technitium:recordList` | List DNS records |
  | `dns:technitium:get` | Get DNS record |
- **Action:** Create `src/utils/dns_technitium.py`

### 🚫 Task 4.4: DHCP Server
- **Status:** 🚫 DEPRECATED
- **Bash:** `src/var/lib/dhcpd.sh` → `deprecated/src/var/lib/dhcpd.sh`
- **Python:** `src/utils/dhcpd.py` → `deprecated/src/utils/dhcpd.py`
- **Commands removed:**
  - `dhcp:setup`
  - `dhcp:config`
  - `sys:dhcp:setup`
  - `sys:dhcp:config`
- **Related service cleanup:** `sys:service:dhcp` removed from active `src/var/lib/sys.service.valid.sh`.
- **Reason:** DHCPD command group and related service validation removed from active Bash and Python CLI surface.

---

## Phase 5: Utilities & Helpers (LOWEST PRIORITY)

### ⏳ Task 5.1: GPG Management
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/gpg.sh` (29 lines)
- **Python:** `src/utils/gpg.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `gpg` | GPG main command |
  | `gpg:export` | Export GPG key |
  | `gpg:import` | Import GPG key |
- **Action:** Create `src/utils/gpg.py`

### ⏳ Task 5.2: CURL/HTTP Utilities
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/curl.sh` (32 lines)
- **Python:** `src/utils/curl.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `curl:get` | HTTP GET request |
  | `curl:gg` | Google search via curl |
- **Action:** Create `src/utils/curl_utils.py`

### ⏳ Task 5.3: File Utilities
- **Status:** ⏳ PENDING (partially done)
- **Bash:** `src/var/lib/file.sh` (16 lines)
- **Python:** `src/utils/file.py` (done: `d_file_cleanpath`)
- **Remaining:**
  | Command | Description |
  |---------|-------------|
  | `file:chmod` | Get file permissions |
  | `file:chmod:files` | chmod all files |
  | `file:chmod:dirs` | chmod all dirs |

### ⏳ Task 5.4: Bash Completion
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/completion.sh` (78 lines)
- **Python:** N/A (likely keep as bash)
- **Target:** Migrate to argcomplete if possible
- **Action:** Review if Python argcomplete can replace

### ⏳ Task 5.5: MSSQL Support
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/mssql.sh` (230 lines)
- **Python:** `src/utils/mssql.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `mssql:install` | Install MSSQL |
  | `mssql:php:install/enable/disable` | PHP SQLSRV driver |
  | `sqlsrv:apt` | APT setup for SQLSRV |
- **Action:** Create `src/utils/mssql.py`

### 🔀 Task 5.6: Sys Service Validation
- **Status:** 🔀 PARTIAL
- **Bash:** `src/var/lib/sys.service.valid.sh` (40 lines)
- **Python:** Merge into `src/utils/system_service.py`
- **Target:** Service validation helpers for httpd, mysql, mssql
- **Removed:** DHCP validation helper `sys:service:dhcp` deprecated with DHCPD command group.
- **Action:** Add to existing `system_service.py`

### ⏳ Task 5.7: Server Install
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/server.sh` (6 lines)
- **Python:** `src/utils/server.py` (TODO)
- **Target Commands:**
  | Command | Description |
  |---------|-------------|
  | `server:install` | Full server setup |
- **Action:** Create `src/utils/server.py`

### ⏳ Task 5.8: Environment Detection (color/text)
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/environment.sh`, `environment.color.sh`, `environment.text.sh`
- **Python:** Already partially in `src/utils/env_detect.py`
- **Remaining:** Color and text environment detection
- **Action:** Merge into `env_detect.py`

### ⏳ Task 5.9: Helper Functions
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/functions.sh` (33 lines)
- **Python:** Internal utilities (not CLI commands)
- **Target:** `--logger`, `--echo`, `--hash_MD5`
- **Action:** Move to `src/utils/helpers.py` if needed

### ⏳ Task 5.10: Main Entry Point
- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/main.sh` (195 lines)
- **Python:** `src/ductn.py` (already replaced)
- **Action:** Confirm no remaining dependencies, deprecate bash file

---

## Migration Rules

1. Each module must have docstrings for all public functions.
2. Register commands with `@register_command` decorator.
3. Support both Linux and macOS where applicable.
4. Do NOT delete bash script until Python equivalent is tested and working.
5. Move deprecated bash scripts to `deprecated/src/var/lib/`.
6. Update this file after each migration.

---

**Total: ~47 remaining bash scripts → ~31 migration tasks**
