# Deprecated Bash Scripts

This folder contains bash scripts that have been migrated to Python modules.

**Structure:** Preserves original path hierarchy (`deprecated/src/var/lib/...`)

## Purpose

- **Backup:** Keep original bash scripts for reference during transition
- **Rollback:** Enable quick rollback if Python migration has issues
- **Documentation:** Show original implementation for understanding
- **Path Preservation:** Maintain original directory structure for easy reference

## Migration Policy

1. Scripts remain here for **30 days** after Python migration
2. After 30 days with no issues → scripts can be permanently deleted
3. If bugs found in Python version → reference bash script for fix

## Migrated Scripts

| Original Path | Deprecated Path | Python Module | Migrated Date | PR |
|---------------|-----------------|---------------|---------------|-----|
| `src/var/lib/apt.sh` | `deprecated/src/var/lib/apt.sh` | `src/utils/apt.py` | 2026-04-18 | #7 |
| `src/var/lib/dns.sh` | `deprecated/src/var/lib/dns.sh` | `src/utils/dns.py` | 2026-04-18 | #9, #10 |

---

## Deprecated Scripts Details

### src/var/lib/apt.sh → apt.py

**Deprecated path:** `src/var/lib/deprecated/src/var/lib/apt.sh`

**Original bash functions:**
- `d_sys:apt:fix()` → `d_apt_fix()`
- `d_sys:apt:check()` → `d_apt_check()`
- `--sys:apt:install()` → `d_apt_install()`
- `--sys:apt:remove()` → `d_apt_remove()`
- `--sys:apt:uninstall()` → `d_apt_uninstall()`

**Python commands:**
```bash
ductn apt:fix              # Fix APT lock files
ductn apt:check <pkg>      # Check if package installed (1=yes, 0=no)
ductn apt:install <pkg>    # Install package if not installed
ductn apt:remove <pkg>     # Remove package with purge
ductn apt:uninstall <pkg>  # Alias for apt:remove
```

---

### src/var/lib/dns.sh → dns.py

**Deprecated path:** `src/var/lib/deprecated/src/var/lib/dns.sh`

**Original bash functions:**
- `--dns:disable()` → `d_dns_disable()`
- `--dns:resolved()` → `d_dns_resolved()`

**Python commands:**
```bash
ductn dns:clean            # Clear DNS cache
ductn dns:reset            # Reset DNS to default (DHCP/network config)
ductn dns:disable          # Disable DNS service (Linux: static DNS, macOS: clean+reset)
ductn dns:resolved         # Re-enable DNS service (Linux: restore systemd, macOS: clean+reset)
ductn dns:watch            # Auto-watch DNS (macOS only)
```

**Key improvements in Python version:**
- Cross-platform support (macOS + Linux)
- Safety checks before modifying /etc/resolv.conf
- Search domain: diepxuan.corp
- Type hints and docstrings
- Better error handling

---

**Note:** Do NOT modify scripts in this folder. They are read-only references.
