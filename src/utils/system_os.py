import os
import platform
import subprocess
import sys

from .registry import register_command
from . import distro

# LINUX = ["linux", "debian", "ubuntu"]
# MACOS = ["darwin"]

# LAUNCHD = ["darwin"]
# SYSTEMD = ["debian", "ubuntu"]


def _sw_vers(flag):
    """Đọc thông tin macOS qua sw_vers (salvage từ src/var/lib/macos/os.sh).

    Module `distro` đọc /etc/os-release — file không tồn tại trên macOS nên
    mọi hàm dưới đây trả rỗng. Bash cũ có bản macos/os.sh dùng sw_vers.
    """
    try:
        result = subprocess.run(
            ["sw_vers", flag],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


def _is_macos():
    return sys.platform == "darwin"


def _os_codename():
    """Get OS codename"""
    if _is_macos():
        # bash: sw_vers -productVersion | awk -F '.' '{print $1"."$2}'
        version = _sw_vers("-productVersion")
        if version:
            return ".".join(version.split(".")[:2])
        return "unknown"
    return distro.codename()


@register_command
def d_os_codename():
    """Get OS codename"""
    print(_os_codename())


def _os_release():
    """Get OS release"""
    if _is_macos():
        # bash: sw_vers -buildVersion  (vd 23F79)
        return _sw_vers("-buildVersion") or "unknown"
    return distro.version()


@register_command
def d_os_release():
    """Get OS release"""
    print(_os_release())


def _os_distro():
    """Get OS distro"""
    if _is_macos():
        # bash: sw_vers -ProductName  (vd macOS)
        return _sw_vers("-ProductName") or "macos"
    return distro.id()


@register_command
def d_os_distro():
    """Get OS distro"""
    print(_os_distro())


def _os_architecture():
    """Get OS architecture"""
    return platform.machine()


@register_command
def d_os_architecture():
    """Get OS architecture"""
    print(_os_architecture())


@register_command
def d_os_type():
    """Get OS type"""
    print(platform.system())


@register_command
def d_os_list():
    """DEPRECATED: Fetches Ubuntu releases list from releases.ubuntu.com.
    This command relies on web scraping and is deprecated.
    """
    print("os:list is deprecated. Use 'ubuntu-distro-info' or check https://releases.ubuntu.com/ directly.")


def _init_system():
    """Get OS Init System"""
    if sys.platform == "darwin":
        return "launchd"
    if os.path.exists("/bin/systemctl") or os.path.exists("/usr/bin/systemctl"):
        return "systemd"
    return "unknown"
