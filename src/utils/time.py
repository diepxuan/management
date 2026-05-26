#!/usr/bin/env python3

"""Cross-platform timezone and NTP time helpers for ductn CLI."""

from __future__ import annotations

import ctypes
import datetime as _dt
import os
import platform
import shutil
import socket
import struct
import subprocess
from typing import Sequence

from .registry import register_command

VIETNAM_TIMEZONE = "Asia/Ho_Chi_Minh"
DEFAULT_NTP_SERVER = "vn.pool.ntp.org"
NTP_DELTA_SECONDS = 2208988800


class TimeCommandError(RuntimeError):
    """Raised when a time command cannot complete."""


def _run(command: Sequence[str]) -> subprocess.CompletedProcess:
    """Run a platform command with inherited stdio."""
    return subprocess.run(list(command), check=False)


def _is_root() -> bool:
    """Return True when the current process has administrative privileges."""
    if os.name == "nt":
        try:
            return bool(ctypes.windll.shell32.IsUserAnAdmin())  # type: ignore[attr-defined]
        except Exception:
            return False
    return hasattr(os, "geteuid") and os.geteuid() == 0


def _sudo_prefix() -> list[str]:
    """Return sudo prefix for Unix-like platforms when needed."""
    if os.name == "nt" or _is_root():
        return []
    if shutil.which("sudo"):
        return ["sudo"]
    return []


def _current_timezone_linux() -> str | None:
    if shutil.which("timedatectl"):
        result = subprocess.run(
            ["timedatectl", "show", "-p", "Timezone", "--value"],
            capture_output=True,
            text=True,
            check=False,
        )
        value = result.stdout.strip()
        if result.returncode == 0 and value:
            return value

    localtime = "/etc/localtime"
    if os.path.islink(localtime):
        target = os.path.realpath(localtime)
        marker = "/zoneinfo/"
        if marker in target:
            return target.split(marker, 1)[1]
    return None


def _current_timezone_macos() -> str | None:
    if not shutil.which("systemsetup"):
        return None
    result = subprocess.run(
        ["systemsetup", "-gettimezone"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    # Example: "Time Zone: Asia/Ho_Chi_Minh"
    text = result.stdout.strip()
    if ":" in text:
        return text.split(":", 1)[1].strip()
    return text or None


def _current_timezone_windows() -> str | None:
    if not shutil.which("tzutil"):
        return None
    result = subprocess.run(
        ["tzutil", "/g"], capture_output=True, text=True, check=False
    )
    if result.returncode == 0:
        return result.stdout.strip() or None
    return None


def current_timezone() -> str | None:
    """Return current system timezone identifier when it can be detected."""
    system = platform.system().lower()
    if system == "linux":
        return _current_timezone_linux()
    if system == "darwin":
        return _current_timezone_macos()
    if system == "windows":
        return _current_timezone_windows()
    return None


def _set_timezone_linux(timezone: str) -> int:
    if shutil.which("timedatectl"):
        return _run([*_sudo_prefix(), "timedatectl", "set-timezone", timezone]).returncode

    zoneinfo = os.path.join("/usr/share/zoneinfo", timezone)
    if not os.path.exists(zoneinfo):
        raise TimeCommandError(f"Không tìm thấy timezone data: {zoneinfo}")
    return _run([*_sudo_prefix(), "ln", "-sfn", zoneinfo, "/etc/localtime"]).returncode


def _set_timezone_macos(timezone: str) -> int:
    if not shutil.which("systemsetup"):
        raise TimeCommandError("Không tìm thấy lệnh systemsetup trên macOS")
    return _run([*_sudo_prefix(), "systemsetup", "-settimezone", timezone]).returncode


def _set_timezone_windows(timezone: str) -> int:
    # Windows timezone ID for Vietnam. tzutil does not accept IANA names.
    windows_tz = "SE Asia Standard Time" if timezone == VIETNAM_TIMEZONE else timezone
    if not shutil.which("tzutil"):
        raise TimeCommandError("Không tìm thấy lệnh tzutil trên Windows")
    return _run(["tzutil", "/s", windows_tz]).returncode


def set_timezone(timezone: str = VIETNAM_TIMEZONE) -> int:
    """Set system timezone cross-platform."""
    system = platform.system().lower()
    if system == "linux":
        return _set_timezone_linux(timezone)
    if system == "darwin":
        return _set_timezone_macos(timezone)
    if system == "windows":
        return _set_timezone_windows(timezone)
    raise TimeCommandError(f"Không hỗ trợ hệ điều hành: {platform.system()}")


def ensure_vietnam_timezone() -> bool:
    """Ensure system timezone is Vietnam timezone. Return True if already correct."""
    current = current_timezone()
    if current in {VIETNAM_TIMEZONE, "SE Asia Standard Time"}:
        print(f"Timezone đã đúng: {current}")
        return True

    print(f"Timezone hiện tại: {current or 'unknown'}")
    print(f"Đang set timezone về {VIETNAM_TIMEZONE}")
    code = set_timezone(VIETNAM_TIMEZONE)
    if code != 0:
        raise TimeCommandError(f"Set timezone thất bại với exit code {code}")
    return False


def get_ntp_time(server: str = DEFAULT_NTP_SERVER, timeout: float = 2.0) -> _dt.datetime:
    """Fetch current UTC time from an NTP server."""
    packet = b"\x1b" + 47 * b"\0"
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.settimeout(timeout)
        sock.sendto(packet, (server, 123))
        data, _ = sock.recvfrom(48)

    if len(data) < 48:
        raise TimeCommandError("NTP response không hợp lệ")
    seconds = struct.unpack("!I", data[40:44])[0] - NTP_DELTA_SECONDS
    return _dt.datetime.fromtimestamp(seconds, tz=_dt.timezone.utc)


def _linux_ntp_enabled() -> bool | None:
    """Return Linux systemd NTP state when timedatectl can report it."""
    if not shutil.which("timedatectl"):
        return None
    result = subprocess.run(
        ["timedatectl", "show", "-p", "NTP", "--value"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    value = result.stdout.strip().lower()
    if value in {"yes", "true", "1"}:
        return True
    if value in {"no", "false", "0"}:
        return False
    return None


def _set_time_linux(dt: _dt.datetime) -> int:
    local = dt.astimezone().strftime("%Y-%m-%d %H:%M:%S")
    if shutil.which("timedatectl"):
        # systemd refuses manual set while NTP sync is active. Preserve and restore
        # the previous NTP state so a one-time sync does not disable continuous sync.
        ntp_was_enabled = _linux_ntp_enabled()
        if ntp_was_enabled:
            disable_result = _run([*_sudo_prefix(), "timedatectl", "set-ntp", "false"])
            if disable_result.returncode != 0:
                return disable_result.returncode
        try:
            return _run([*_sudo_prefix(), "timedatectl", "set-time", local]).returncode
        finally:
            if ntp_was_enabled:
                _run([*_sudo_prefix(), "timedatectl", "set-ntp", "true"])
    return _run([*_sudo_prefix(), "date", "-s", local]).returncode


def _set_time_macos(dt: _dt.datetime) -> int:
    if not shutil.which("date"):
        raise TimeCommandError("Không tìm thấy lệnh date trên macOS")
    local = dt.astimezone().strftime("%m%d%H%M%Y.%S")
    return _run([*_sudo_prefix(), "date", local]).returncode


def _set_time_windows(dt: _dt.datetime) -> int:
    local = dt.astimezone()
    # PowerShell Set-Date can set both date and time in one call.
    powershell = shutil.which("powershell") or shutil.which("pwsh")
    if not powershell:
        raise TimeCommandError("Không tìm thấy PowerShell trên Windows")
    timestamp = local.strftime("%Y-%m-%d %H:%M:%S")
    return _run([powershell, "-NoProfile", "-Command", f"Set-Date -Date '{timestamp}'"]).returncode


def set_system_time(dt: _dt.datetime) -> int:
    """Set system time cross-platform from a timezone-aware datetime."""
    system = platform.system().lower()
    if system == "linux":
        return _set_time_linux(dt)
    if system == "darwin":
        return _set_time_macos(dt)
    if system == "windows":
        return _set_time_windows(dt)
    raise TimeCommandError(f"Không hỗ trợ hệ điều hành: {platform.system()}")


def sync_time(server: str = DEFAULT_NTP_SERVER) -> _dt.datetime:
    """Fetch NTP time and set local system clock."""
    ntp_time = get_ntp_time(server)
    print(f"NTP UTC time: {ntp_time.isoformat()}")
    code = set_system_time(ntp_time)
    if code != 0:
        raise TimeCommandError(f"Set system time thất bại với exit code {code}")
    return ntp_time


@register_command("time:timezone")
def d_time_timezone(args=None):
    """Kiểm tra hoặc set timezone về Việt Nam."""
    args = args or []
    if args and args[0] in {"--current", "current"}:
        print(current_timezone() or "unknown")
        return
    ensure_vietnam_timezone()


@register_command("timezone:vietnam", "time:vietnam")
def d_time_timezone_vietnam(args=None):
    """Set timezone hệ thống về Asia/Ho_Chi_Minh."""
    ensure_vietnam_timezone()


@register_command("time:sync")
def d_time_sync(args=None):
    """Đồng bộ giờ hệ thống từ NTP server."""
    args = args or []
    server = args[0] if args else DEFAULT_NTP_SERVER
    sync_time(server)


@register_command("time:init")
def d_time_init(args=None):
    """Set timezone Việt Nam rồi đồng bộ giờ từ NTP."""
    args = args or []
    server = args[0] if args else DEFAULT_NTP_SERVER
    ensure_vietnam_timezone()
    sync_time(server)
