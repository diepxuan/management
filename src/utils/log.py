#!/usr/bin/env python3
"""Log management commands: watch, cleanup, logrotate config."""

import glob
import logging
import os
import shutil
import subprocess
import sys

from .registry import register_command
from .system import _is_root

LOGROTATE_DUCTN = "/etc/logrotate.d/ductn"


@register_command
def d_log():
    """Show system logs (alias for log:watch)."""
    d_log_watch()


def _find_log_files():
    """Find log files to watch: /var/log/*log and mssql errorlog."""
    files = glob.glob("/var/log/*log")
    mssql_log = "/var/opt/mssql/log/errorlog"
    if os.path.exists(mssql_log):
        files.append(mssql_log)
    return sorted(set(f for f in files if os.path.isfile(f)))


@register_command
def d_log_watch(args=None):
    """Watch logs in real-time.

    Usage:
      ductn log:watch           — tail all /var/log/*log files
      ductn log:watch nginx     — journalctl -u nginx.service -f
      ductn log:watch nginx.service  — same, strips .service suffix
    """
    if args:
        if isinstance(args, list):
            service = args[0]
        else:
            service = str(args)
        service = service.replace(".service", "")
        cmd = ["journalctl", "-u", f"{service}.service", "-f"]
    else:
        files = _find_log_files()
        if not files:
            print("No log files found in /var/log", file=sys.stderr)
            return
        cmd = ["tail", "-f"] + files

    try:
        subprocess.run(cmd)
    except KeyboardInterrupt:
        pass


@register_command
def d_log_cleanup(args=None):
    """Clean up log files: truncate logs, remove rotated files, clear trash.

    Requires root. Asks for confirmation before proceeding.
    """
    if not _is_root():
        print("Error: root required (sudo)", file=sys.stderr)
        sys.exit(1)

    # Confirmation prompt (skip if args contains --yes)
    force = args and "--yes" in args
    if not force:
        print("This will truncate ALL logs in /var/log, delete rotated logs,")
        print("and clear system trash. Continue? [y/N] ", end="", flush=True)
        try:
            resp = sys.stdin.readline().strip().lower()
        except (EOFError, KeyboardInterrupt):
            print()
            return
        if resp not in ("y", "yes"):
            print("Aborted.")
            return

    # 1. Truncate all files under /var/log
    log_files = glob.glob("/var/log/**/*", recursive=True)
    log_files += glob.glob("/var/log/*")
    truncated = 0
    for f in set(log_files):
        if os.path.isfile(f):
            try:
                with open(f, "w") as fh:
                    pass
                truncated += 1
            except (PermissionError, OSError):
                pass
    print(f"Truncated {truncated} log files")

    # 2. Remove rotated logs (.gz, .1, .2, ...)
    patterns = ["/var/log/**/*.gz", "/var/log/**/*.?"]
    # Also clean mssql logs if present
    if os.path.isdir("/var/opt/mssql/log"):
        patterns += ["/var/opt/mssql/log/**/*.gz", "/var/opt/mssql/log/**/*.?[0-9]*"]

    removed = 0
    for pat in patterns:
        for f in glob.glob(pat, recursive=True):
            try:
                os.remove(f)
                removed += 1
            except (PermissionError, OSError):
                pass
    print(f"Removed {removed} rotated log files")

    # 3. Clear trash
    for trash_path in ["/home/*/.local/share/Trash", "/root/.local/share/Trash"]:
        expanded = glob.glob(trash_path)
        for t in expanded:
            if os.path.isdir(t):
                try:
                    shutil.rmtree(t, ignore_errors=True)
                except OSError:
                    pass
    print("Cleared trash")


def _user_exists(username: str) -> bool:
    """Check if a system user exists."""
    try:
        import pwd
        pwd.getpwnam(username)
        return True
    except KeyError:
        return False


def _log_config_store() -> str:
    """Logrotate config for store user (Magento)."""
    if not _user_exists("store"):
        return ""
    return """/home/store/public_html/var/log/*.log {
    su store www-data
    size 1M
    copytruncate
    rotate 1
}
"""


def _log_config_mssql() -> str:
    """Logrotate config for MSSQL logs."""
    if not _user_exists("mssql"):
        return ""
    return """/var/opt/mssql/log/errorlog /var/opt/mssql/log/*.log {
    su mssql mssql
    size 10M
    copytruncate
    missingok
    rotate 1
}
"""


@register_command
def d_log_config():
    """Generate and apply logrotate config for ductn.

    Writes /etc/logrotate.d/ductn with configs for store (if exists)
    and mssql (if exists), then runs logrotate -f.
    """
    if not _is_root():
        print("Error: root required (sudo)", file=sys.stderr)
        sys.exit(1)

    # Build config
    parts = []
    store_cfg = _log_config_store()
    if store_cfg:
        parts.append(store_cfg)
    mssql_cfg = _log_config_mssql()
    if mssql_cfg:
        parts.append(mssql_cfg)

    if not parts:
        print("No matching users (store, mssql) found — config empty.")
        # Still write empty file to reset
        open(LOGROTATE_DUCTN, "w").close()
        return

    config = "\n".join(parts)

    # Write config
    with open(LOGROTATE_DUCTN, "w") as f:
        f.write(config)
    print(f"Wrote {LOGROTATE_DUCTN}")

    # Run logrotate
    try:
        subprocess.check_call(["logrotate", "-f", LOGROTATE_DUCTN])
        print("Logrotate applied successfully")
    except subprocess.CalledProcessError as e:
        print(f"Logrotate failed: {e}", file=sys.stderr)
        sys.exit(1)
