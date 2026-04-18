# TASKS.md - Bash to Python Migration

**Project:** ductn (DiepXuan Personal Package)  
**Created:** 2026-04-18  
**Goal:** Migrate bash scripts from `src/var/lib/` to Python modules in `src/utils/`

---

## Migration Status

| Status | Count | Description |
|--------|-------|-------------|
| ✅ Completed | 2 | Already migrated to Python |
| 🔄 In Progress | 0 | Currently being migrated |
| ⏳ Pending | 47 | Waiting to be migrated |
| 🚫 Deprecated | 1 | Bash scripts moved to deprecated/ |

---

## Phase 1: Core Infrastructure (HIGH PRIORITY)

### ✅ Task 1.1: APT Package Management

- **Status:** ✅ COMPLETED
- **Bash:** `src/var/lib/apt.sh` (1402 bytes)
- **Python:** `src/utils/apt.py` (5271 bytes, 184 lines)
- **Commands:** `apt:fix`, `apt:check`, `apt:install`, `apt:remove`, `apt:uninstall`
- **PR:** #7 (merged)
- **Action:** Move `src/var/lib/apt.sh` → `src/var/lib/deprecated/apt.sh`

---

### ✅ Task 1.2: DNS Management

- **Status:** ✅ COMPLETED
- **PR:** #9 (pending review)
- **Bash:** `src/var/lib/dns.sh` (1159 bytes)
- **Python:** `src/utils/dns.py` (109 lines, existing)
- **Target Commands:**

| Command | Description | Platform |
|---------|-------------|----------|
| `dns:clean` | Clear DNS cache | macOS + Linux |
| `dns:reset` | Reset DNS to default | macOS + Linux |
| `dns:watch` | Auto-watch DNS and fix if needed | macOS + Linux |
| `dns:disable` | Disable systemd-resolved, set static DNS (Linux) OR clean+reset (macOS) | macOS + Linux |
| `dns:resolved` | Re-enable systemd-resolved (Linux) OR clean+reset (macOS) | macOS + Linux |

- **Platform Behavior:**

| Command | Linux | macOS |
|---------|-------|-------|
| `dns:clean` | `resolvectl flush` or `systemd-resolve --flush-caches` | `dscacheutil -flushcache` + `killall -HUP mDNSResponder` |
| `dns:reset` | Restore systemd-resolved symlink | `networksetup -setdnsservers <service> empty` |
| `dns:disable` | Stop systemd-resolved, set static DNS (1.1.1.1, 8.8.8.8) | **Alias:** `dns:clean` + `dns:reset` |
| `dns:resolved` | Restore systemd-resolved | **Alias:** `dns:clean` + `dns:reset` |
| `dns:watch` | Auto-watch and fix DNS | Auto-watch and fix DNS |

- **Requirements:**

1. **`dns:clean`** - Clear DNS cache
   - **macOS:** `dscacheutil -flushcache` + `killall -HUP mDNSResponder`
   - **Linux:** `systemd-resolve --flush-caches` or `resolvectl flush`

2. **`dns:reset`** - Reset DNS to default
   - **macOS:** `networksetup -setdnsservers <service> empty`
   - **Linux:** Restore systemd-resolved symlink, restart service

3. **`dns:watch`** - Auto-watch DNS (refactor from `macos_dns_watch`)
   - Check connectivity (ping DNS server)
   - Check DNS resolution (dig query)
   - Auto-fix if DNS fails
   - **Platform:** Support both macOS and Linux
   - **Implementation:** Detect platform, use appropriate commands

4. **`dns:disable`** - Disable DNS services
   - **Linux:** 
     - Stop systemd-resolved service
     - Set static DNS (1.1.1.1, 8.8.8.8)
   - **macOS:** 
     - **Alias:** `dns:clean` + `dns:reset` (combined operation)
     - Flush DNS cache + reset to default DNS

5. **`dns:resolved`** - Re-enable DNS services
   - **Linux:** 
     - Restore symlink
     - Enable and restart service
   - **macOS:** 
     - **Alias:** `dns:clean` + `dns:reset` (combined operation)
     - Flush DNS cache + reset to default DNS

- **Implementation Plan:**

| Step | Task | Estimated Time |
|------|------|----------------|
| 1 | Refactor `macos_dns_watch()` → `d_dns_watch()` with cross-platform support | 30 min |
| 2 | Enhance `d_dns_clean()` with Linux support | 15 min |
| 3 | Enhance `d_dns_reset()` with Linux support | 15 min |
| 4 | Add `d_dns_disable()` for Linux | 20 min |
| 5 | Add `d_dns_resolved()` for Linux | 20 min |
| 6 | Add docstrings + type hints | 15 min |
| 7 | Add error handling (try/except) | 15 min |
| 8 | Test on Linux + macOS | 30 min |
| 9 | Add unit tests | 30 min |
| 10 | Update `src/utils/service.py` (service:watch integration) | 20 min |
| 11 | Move `dns.sh` to deprecated/ | 5 min |

**Total:** ~3.5 hours

- **Action:** 
  1. Enhance `src/utils/dns.py` with cross-platform support
  2. Update `src/utils/service.py` to integrate dns:watch
  3. Test both platforms
  4. Deprecate bash script

- **service.py Updates Required:**

After completing dns.py enhancement, update `src/utils/service.py`:

```python
# Current code (macOS only):
from .dns import macos_dns_watch
scheduler.register(
    name="macos_dns_watch",
    interval=10,
    target=macos_dns_watch,
    init="launchd",
)

# New code (macOS only - Linux doesn't need dns:watch):
from .dns import d_dns_watch
scheduler.register(
    name="dns_watch",
    interval=10,
    target=d_dns_watch,
    init="launchd",  # macOS only
)
# Note: Linux does NOT register dns:watch (systemd-resolved handles DNS automatically)
```

**Changes:**
- Rename `macos_dns_watch` → `d_dns_watch`
- Make it cross-platform (detect Linux vs macOS)
- Register for `launchd` only (macOS)
- **Linux:** No scheduler registration needed (systemd-resolved handles DNS automatically)
- Update import statement

---

### ⏳ Task 1.3: VM Detection & Sync

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/vm.sh` (size TBD)
- **Python:** `src/utils/vm.py` (139 lines, existing)
- **Commands to migrate:**
  - `d_vm:info` → Already in Python
  - `d_vm:sync` → Already in Python
  - Check bash for additional functions
- **Action:** Review bash file, enhance Python if needed, then deprecate bash

---

### ⏳ Task 1.4: Service Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/service.sh` (size TBD)
- **Python:** `src/utils/service.py` (171 lines, existing)
- **Commands to migrate:**
  - `d_service:*` → Partially in Python
  - Check bash for additional functions
- **Action:** Review bash file, enhance Python if needed, then deprecate bash

---

### ⏳ Task 1.5: System Information

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/os.sh` (2249 bytes), `src/var/lib/host.sh` (2413 bytes)
- **Python:** `src/utils/system_os.py`, `src/utils/host.py`, `src/utils/system_info.py`
- **Commands to migrate:**
  - `d_os:*` functions
  - `d_host:*` functions
- **Action:** Review bash files, ensure Python has all functions, then deprecate bash

---

## Phase 2: Network & Connectivity (MEDIUM PRIORITY)

### ⏳ Task 2.1: IP Address Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ip.sh` (4470 bytes)
- **Python:** `src/utils/addr.py` (254 lines, existing)
- **Commands to migrate:**
  - `d_ip:local`, `d_ip:locals`, `d_ip:wan` → Already in Python
  - Check bash for additional functions
- **Action:** Review bash file, enhance Python if needed, then deprecate bash

---

### ⏳ Task 2.2: Network Routing

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/route.sh` (size TBD)
- **Python:** `src/utils/route.py` (235 lines, existing)
- **Commands to migrate:**
  - `d_route:default`, `d_route:monitor` → Already in Python
  - Check bash for additional functions
- **Action:** Review bash file, enhance Python if needed, then deprecate bash

---

### ⏳ Task 2.3: WireGuard VPN

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/wg.sh` (size TBD)
- **Python:** `src/utils/wg.py` (143 lines, existing)
- **Commands to migrate:**
  - Check bash for functions not in Python
- **Action:** Review bash file, enhance Python if needed, then deprecate bash

---

### ⏳ Task 2.4: Interface Management

- **Status:** ⏳ PENDING
- **Bash:** (check in env.sh or dedicated file)
- **Python:** `src/utils/interface.py` (65 lines, existing)
- **Commands:** `d_interface:default`, `d_interface:service`
- **Action:** Review and ensure parity

---

## Phase 3: System Utilities (MEDIUM PRIORITY)

### ⏳ Task 3.1: File Operations

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/file.sh` (308 bytes)
- **Python:** `src/utils/file.py` (62 lines, existing)
- **Commands:** `d_file:cleanpath`
- **Action:** Review bash file, ensure Python has all functions, then deprecate bash

---

### ⏳ Task 3.2: Environment Detection

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/env.sh` (3991 bytes)
- **Python:** `src/utils/env_detect.py` (96 lines, existing)
- **Commands:** `d_env:detect`
- **Action:** Review bash file, ensure Python has all functions, then deprecate bash

---

### ⏳ Task 3.3: System Commands

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/sys.sh` (check if exists)
- **Python:** `src/utils/system.py` (136 lines, existing)
- **Commands:** `d_sys:*`
- **Action:** Review and ensure parity

---

### ⏳ Task 3.4: Logging System

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/log.sh` (3356 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Log rotation
  - Log levels
  - Syslog integration
- **Action:** Create `src/utils/logger.py`, migrate functions, deprecate bash

---

## Phase 4: Application Support (LOW PRIORITY)

### ⏳ Task 4.1: PHP/Laravel Support

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/php.sh`, `src/var/lib/php.lar.sh`, `src/var/lib/php.m2.sh`
- **Python:** (new module needed)
- **Functions to migrate:**
  - Laravel commands
  - Magento 2 commands
  - PHP-FPM management
- **Action:** Create `src/utils/php.py`, migrate functions, deprecate bash

---

### ⏳ Task 4.2: MySQL/MariaDB Support

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/mysql.sh` (1489 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - MySQL service management
  - Database operations
- **Action:** Create `src/utils/mysql.py`, migrate functions, deprecate bash

---

### ⏳ Task 4.3: MSSQL Support

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/mssql.sh` (10118 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - MSSQL service management
  - Database operations
- **Action:** Create `src/utils/mssql.py`, migrate functions, deprecate bash

---

### ⏳ Task 4.4: HTTPD/Web Server

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/httpd.sh` (6446 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Apache/Nginx management
  - Virtual host management
- **Action:** Create `src/utils/httpd.py`, migrate functions, deprecate bash

---

## Phase 5: Security & Maintenance (LOW PRIORITY)

### ⏳ Task 5.1: CSF Firewall

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/csf.sh` (3893 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - CSF configuration
  - Firewall rules
- **Action:** Create `src/utils/csf.py`, migrate functions, deprecate bash

---

### ⏳ Task 5.2: SSH Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ssh.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - SSH config
  - Key management
- **Action:** Create `src/utils/ssh.py`, migrate functions, deprecate bash

---

### ⏳ Task 5.3: SSL/TLS Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ssl.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Certificate management
  - Let's Encrypt integration
- **Action:** Create `src/utils/ssl.py`, migrate functions, deprecate bash

---

### ⏳ Task 5.4: Git Operations

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/git.sh` (4189 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Git config
  - Repository operations
- **Action:** Create `src/utils/git_ops.py`, migrate functions, deprecate bash

---

### ⏳ Task 5.5: GPG Operations

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/gpg.sh` (688 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - GPG key management
  - Sign/verify operations
- **Action:** Create `src/utils/gpg.py`, migrate functions, deprecate bash

---

## Phase 6: User Experience (LOW PRIORITY)

### ⏳ Task 6.1: Environment/Output Formatting

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/environment.sh`, `environment.color.sh`, `environment.text.sh`
- **Python:** (enhance existing or new module)
- **Functions to migrate:**
  - Color output
  - Text formatting
  - Environment detection
- **Action:** Enhance `src/utils/env_detect.py` or create `src/utils/output.py`

---

### ⏳ Task 6.2: Help System

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/help.sh` (1832 bytes)
- **Python:** (enhance existing)
- **Functions to migrate:**
  - Help text generation
  - Command descriptions
- **Action:** Enhance `src/utils/command.py` or `src/utils/about.py`

---

### ⏳ Task 6.3: Alias Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/alias.sh` (560 bytes)
- **Python:** `src/utils/alias.py` (27 lines, existing)
- **Commands:** `d_alias:ll`
- **Action:** Review bash file, ensure Python has all functions, then deprecate bash

---

## Phase 7: Infrastructure (LOW PRIORITY)

### ⏳ Task 7.1: Cron Job Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/cronjob.sh` (318 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Cron job creation
  - Schedule management
- **Action:** Create `src/utils/cron.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.2: DDNS (Dynamic DNS)

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ddns.sh` (1498 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - DDNS updates
  - DNS provider integration
- **Action:** Create `src/utils/ddns.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.3: DHCP Server

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/dhcpd.sh` (2117 bytes)
- **Python:** (new module needed)
- **Functions to migrate:**
  - DHCP config
  - Lease management
- **Action:** Create `src/utils/dhcp.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.4: Disk Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/disk.sh` (1871 bytes)
- **Python:** `src/utils/libsysinfo/disk.py` (existing)
- **Functions to migrate:**
  - Disk info
  - Partition management
- **Action:** Review bash file, ensure Python has all functions, then deprecate bash

---

### ⏳ Task 7.5: User Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/user.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - User creation/deletion
  - Permission management
- **Action:** Create `src/utils/user.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.6: SWAP Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/swap.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - SWAP creation/management
- **Action:** Create `src/utils/swap.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.7: UFW Firewall

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/ufw.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - UFW configuration
  - Rule management
- **Action:** Create `src/utils/ufw.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.8: Server Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/server.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Server info
  - Server management
- **Action:** Create `src/utils/server.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.9: Port Management

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/port.sh` (check if exists)
- **Python:** (new module needed)
- **Functions to migrate:**
  - Port forwarding
  - Port checking
- **Action:** Create `src/utils/port.py`, migrate functions, deprecate bash

---

### ⏳ Task 7.10: Main Entry Point

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/main.sh` (9340 bytes)
- **Python:** `src/ductn.py` (existing)
- **Functions to migrate:**
  - Main CLI logic (already in Python)
  - Check for any remaining bash functions
- **Action:** Review bash file, ensure all logic is in Python, then deprecate bash

---

### ⏳ Task 7.11: DNS Technitium

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/dns.technitium.sh` (697 bytes)
- **Python:** (enhance dns.py or new module)
- **Functions to migrate:**
  - Technitium DNS integration
- **Action:** Enhance `src/utils/dns.py` with Technitium support

---

### ⏳ Task 7.12: cURL Utilities

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/curl.sh` (901 bytes)
- **Python:** (use requests library, enhance utils)
- **Functions to migrate:**
  - cURL wrapper functions
- **Action:** Use Python `requests` library, no new module needed

---

### ⏳ Task 7.13: Completion Script

- **Status:** ⏳ PENDING
- **Bash:** `src/var/lib/completion.sh` (2867 bytes)
- **Python:** (argcomplete already in use)
- **Functions to migrate:**
  - Bash completion (already handled by argcomplete)
- **Action:** Keep bash completion script or migrate to Python argcomplete

---

## Deprecated Scripts

Scripts that have been successfully migrated to Python:

| Bash Script | Python Module | Migrated Date | PR |
|-------------|---------------|---------------|-----|
| `src/var/lib/apt.sh` | `src/utils/apt.py` | 2026-04-18 | #7 |

---

## Migration Checklist

For each bash script:

- [ ] Review bash functions and document them
- [ ] Check if Python module already exists
- [ ] Create/enhance Python module with all functions
- [ ] Add docstrings for all functions
- [ ] Add type hints
- [ ] Register commands in registry.py
- [ ] Test all commands manually
- [ ] Add unit tests (pytest)
- [ ] Update TOOLS.md with new commands
- [ ] Update changelog
- [ ] Move bash script to `src/var/lib/deprecated/`
- [ ] Create PR for review

---

## Notes

- **Priority levels:**
  - HIGH: Core infrastructure, frequently used commands
  - MEDIUM: Network, system utilities
  - LOW: Application support, optional features

- **Migration principles:**
  - Maintain backward compatibility during migration
  - Keep bash scripts until Python version is tested and merged
  - Add comprehensive tests for Python modules
  - Document all commands with docstrings

- **Testing requirements:**
  - Unit tests for each function (pytest)
  - Integration tests for commands
  - Coverage target: >80%

---

**Last updated:** 2026-04-18  
**Next review:** After each migration task completion
