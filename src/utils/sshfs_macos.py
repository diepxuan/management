#!/usr/bin/env python3
"""macOS SSHFS mount helpers (salvaged from src/var/lib/macos/sshfs.sh).

The bash version installed ``sshfs-mac`` via Homebrew and managed a launchd
daemon that mounted a remote directory at login.

The plist is templated from arguments instead of hardcoding the machine it was
written on (``root@web.diepxuan.corp:/var/www/laravel`` ->
``/Users/ductn/Developer/laravel``, with ``IdentityFile=/Users/ductn/.ssh/id_rsa``).
The SSH key is taken from ``$DUCTN_SSHFS_IDENTITY`` or the user's default.
"""

import logging
import os
import shutil
import subprocess
import sys

from .registry import register_command

LAUNCHD_LABEL = "com.user.sshfs"
LAUNCHD_PLIST = f"/Library/LaunchDaemons/{LAUNCHD_LABEL}.plist"

PLIST_TEMPLATE = """\
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.sshfs</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/sshfs</string>
        <string>-o</string>
        <string>auto_cache,reconnect,allow_other,IdentityFile={identity}</string>
        <string>{remote}</string>
        <string>{mountpoint}</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>ThrottleInterval</key>
    <integer>10</integer>

    <key>StandardOutPath</key>
    <string>/Library/Logs/com.user.sshfs.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Library/Logs/com.user.sshfs.err.log</string>
</dict>
</plist>
"""


def _require_macos():
    if sys.platform != "darwin":
        logging.error("Nhóm lệnh này chỉ hỗ trợ macOS")
        return False
    return True


def _run(cmd, check=False):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, check=check)
    except FileNotFoundError:
        logging.error("Không tìm thấy lệnh: %s", cmd[0])
        return None
    except subprocess.CalledProcessError as e:
        logging.error("%s thất bại: %s", " ".join(cmd), e.stderr.strip())
        return None


@register_command
def d_sshfs_install():
    """
    Cài sshfs qua Homebrew (macOS).
    Usage: ductn sshfs:install
    """
    if not _require_macos():
        return

    if shutil.which("sshfs"):
        logging.info("sshfs đã được cài")
        return

    if not shutil.which("brew"):
        logging.error("Chưa có Homebrew. Xem https://brew.sh")
        return

    _run(["brew", "install", "gromgit/fuse/sshfs-mac"])
    logging.info("Đã cài sshfs")


@register_command
def d_sshfs_service_install(args=None):
    """
    Cài launchd service mount SSHFS (macOS).
    Usage: ductn sshfs:service:install <remote>:<path> <mountpoint>

    Ví dụ:
      ductn sshfs:service:install root@web.diepxuan.corp:/var/www/laravel \\
        /Users/ductn/Developer/laravel

    SSH key lấy từ $DUCTN_SSHFS_IDENTITY, mặc định ~/.ssh/id_rsa.
    """
    if not _require_macos():
        return

    from .system import _is_root as _root

    if not _root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 2:
        logging.error(
            "Usage: ductn sshfs:service:install <remote>:<path> <mountpoint>"
        )
        return

    remote, mountpoint = args[0], args[1]
    identity = os.environ.get(
        "DUCTN_SSHFS_IDENTITY",
        os.path.expanduser("~/.ssh/id_rsa"),
    )

    if not os.path.isfile(identity):
        logging.warning("Không thấy SSH key %s — service có thể không mount được", identity)

    content = PLIST_TEMPLATE.format(
        identity=identity,
        remote=remote,
        mountpoint=mountpoint,
    )

    d_sshfs_install()

    try:
        os.makedirs(mountpoint, exist_ok=True)
        with open(LAUNCHD_PLIST, "w", encoding="utf-8") as f:
            f.write(content)
        os.chmod(LAUNCHD_PLIST, 0o644)
    except OSError as e:
        logging.error("Không ghi được %s: %s", LAUNCHD_PLIST, e)
        return

    logging.info("Đã ghi %s", LAUNCHD_PLIST)
    d_sshfs_service_restart()


@register_command
def d_sshfs_service_start():
    """
    Khởi động SSHFS service (macOS).
    Usage: ductn sshfs:service:start
    """
    if not _require_macos():
        return

    if not os.path.isfile(LAUNCHD_PLIST):
        logging.error("Chưa có plist. Chạy trước: ductn sshfs:service:install")
        return

    _run(["launchctl", "bootstrap", "system", LAUNCHD_PLIST])
    _run(["launchctl", "enable", f"system/{LAUNCHD_LABEL}"])
    logging.info("SSHFS service đã start")


@register_command
def d_sshfs_service_stop():
    """
    Dừng SSHFS service (macOS).
    Usage: ductn sshfs:service:stop
    """
    if not _require_macos():
        return

    _run(["launchctl", "bootout", "system", LAUNCHD_PLIST])
    logging.info("SSHFS service đã stop")


@register_command
def d_sshfs_service_restart():
    """
    Khởi động lại SSHFS service (macOS).
    Usage: ductn sshfs:service:restart
    """
    if not _require_macos():
        return

    d_sshfs_service_stop()
    d_sshfs_service_start()
