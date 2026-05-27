#!/usr/bin/env python3
"""APT package management utilities."""

import os
import re
import signal
import subprocess
import sys

from .registry import register_command
from .system import _is_root

_PACKAGE_RE = re.compile(r"^[A-Za-z0-9][A-Za-z0-9+._:-]*$")
LOCK_FILES = [
    "/var/lib/apt/lists/lock",
    "/var/cache/apt/archives/lock",
    "/var/lib/dpkg/lock",
    "/var/lib/dpkg/lock-frontend",
]
LOCK_PROCESS_NAMES = ("apt", "apt-get", "aptitude", "dpkg", "unattended-upgrade")


def _run_argv(argv):
    """Run command without shell expansion."""
    try:
        result = subprocess.run(
            argv,
            check=False,
            capture_output=True,
            text=True,
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return 1, "", str(e)


def _with_sudo(argv):
    """Prefix sudo when current process is not root."""
    if _is_root():
        return argv
    return ["sudo"] + argv


def _normalize_args(args):
    if args is None:
        return []
    if isinstance(args, str):
        return args.split()
    return list(args)


def _validate_package_name(package):
    if not package or not _PACKAGE_RE.match(package):
        print(f"Invalid package name: {package}", file=sys.stderr)
        sys.exit(2)


def _is_installed(package):
    _validate_package_name(package)
    code, stdout, _stderr = _run_argv([
        "dpkg-query",
        "-W",
        "-f=${Status}",
        package,
    ])
    return code == 0 and "install ok installed" in stdout


def _pid_command(pid):
    try:
        with open(f"/proc/{pid}/cmdline", "rb") as f:
            raw = f.read().replace(b"\x00", b" ").strip()
        if raw:
            return raw.decode(errors="replace")
    except OSError:
        pass

    code, stdout, _stderr = _run_argv(["ps", "-p", str(pid), "-o", "comm="])
    return stdout.strip() if code == 0 and stdout.strip() else "unknown"


def _find_lock_holders():
    """Return {pid: command} for processes holding APT/dpkg locks."""
    holders = {}
    for lock_file in LOCK_FILES:
        if not os.path.exists(lock_file):
            continue
        code, stdout, _stderr = _run_argv(["fuser", lock_file])
        if code != 0 or not stdout.strip():
            continue
        for token in stdout.split():
            try:
                pid = int(token)
            except ValueError:
                continue
            holders[pid] = _pid_command(pid)
    return holders


def _find_apt_like_processes():
    """Best-effort fallback: find apt/dpkg processes even when fuser is unavailable."""
    code, stdout, _stderr = _run_argv(["ps", "-eo", "pid=,comm=,args="])
    if code != 0:
        return {}

    current_pid = os.getpid()
    holders = {}
    for line in stdout.splitlines():
        parts = line.strip().split(None, 2)
        if len(parts) < 2:
            continue
        try:
            pid = int(parts[0])
        except ValueError:
            continue
        if pid == current_pid:
            continue
        comm = parts[1]
        args = parts[2] if len(parts) > 2 else comm
        if comm in LOCK_PROCESS_NAMES:
            holders[pid] = args
    return holders


def _remove_lock_files():
    """Remove lock files only after caller confirms no holder or force killed holders."""
    for lock_file in LOCK_FILES:
        if not os.path.exists(lock_file):
            continue
        try:
            if _is_root():
                os.remove(lock_file)
            else:
                code, _stdout, stderr = _run_argv(["sudo", "rm", "-f", lock_file])
                if code != 0:
                    print(f"Cannot remove {lock_file}: {stderr}", file=sys.stderr)
                    sys.exit(1)
            print(f"Removed stale lock: {lock_file}")
        except OSError as e:
            print(f"Cannot remove {lock_file}: {e}", file=sys.stderr)
            sys.exit(1)


def _kill_processes(pids):
    """Kill exact lock-holder PIDs. Never use killall."""
    for pid in pids:
        print(f"Killing lock holder PID {pid}")
        if _is_root():
            try:
                os.kill(pid, signal.SIGTERM)
            except ProcessLookupError:
                continue
            except OSError as e:
                print(f"Cannot kill PID {pid}: {e}", file=sys.stderr)
                sys.exit(1)
        else:
            code, _stdout, stderr = _run_argv(["sudo", "kill", "-TERM", str(pid)])
            if code != 0:
                print(f"Cannot kill PID {pid}: {stderr}", file=sys.stderr)
                sys.exit(1)


def _run_repair_steps():
    for cmd in (["dpkg", "--configure", "-a"], ["apt-get", "-f", "install", "-y"]):
        code, _stdout, stderr = _run_argv(_with_sudo(cmd))
        if code != 0:
            print(f"Error running {' '.join(cmd)}: {stderr}", file=sys.stderr)
            sys.exit(1)


@register_command
def d_apt_fix(args=None):
    """Repair APT/dpkg locks and interrupted state. Usage: ductn apt:fix [-f|--force]"""
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:fix [-f|--force]")
        print("Without force: repair what is safe; remove stale locks only when no holder exists.")
        print("With force: kill exact lock-holder PIDs, remove locks, then repair.")
        return

    force = "--force" in args or "-f" in args
    holders = _find_lock_holders()
    if not holders:
        holders = _find_apt_like_processes()

    if holders and not force:
        print("APT/dpkg lock is held by active process(es):", file=sys.stderr)
        for pid, command in sorted(holders.items()):
            print(f"  PID {pid}: {command}", file=sys.stderr)
        print("", file=sys.stderr)
        print("Nếu process đang chạy hợp lệ: chờ nó hoàn tất rồi chạy lại `ductn apt:fix`.", file=sys.stderr)
        print("Nếu process treo/lỗi lock: chạy `ductn apt:fix --force` hoặc `ductn apt:fix -f` để kill đúng PID đang giữ lock.", file=sys.stderr)
        sys.exit(3)

    if holders and force:
        _kill_processes(sorted(holders))

    _remove_lock_files()
    print("Repairing APT/dpkg state...")
    _run_repair_steps()
    print("APT/dpkg repair completed.")


@register_command
def d_apt_check(args=None):
    """Check if package is installed. Usage: ductn apt:check <package>"""
    args = _normalize_args(args)
    if "--help" in args:
        print("Usage: ductn apt:check <package>")
        return
    if not args:
        print("Error: package name required", file=sys.stderr)
        sys.exit(1)
    print("1" if _is_installed(args[0]) else "0")
