#!/usr/bin/env python3
"""macOS WireGuard helpers (salvaged from src/var/lib/macos/wg.sh).

The bash version only ran on macOS: it installed ``wireguard-tools`` via
Homebrew, wrote a launchd plist to ``/Library/LaunchDaemons``, and controlled
the tunnel with ``launchctl bootstrap/bootout``.

Two parts are deliberately *not* carried over:

1. ``wg:hotfix`` — it generated a bash wrapper at
   ``/opt/homebrew/bin/wg-quick-bash5`` containing a 5-second ``while true``
   loop calling ``ductn dns:set 10.10.x.x``. That loop never exits, fights
   with DHCP, and hardcodes diepxuan-internal DNS addresses. The problem it
   worked around (wg-quick resetting DNS on macOS) is better solved with
   ``WG_QUICK_DNS_SKIP=1``, which the same file already referenced.
2. ``wg:fix`` — it renamed network services by stripping leading
   underscores/spaces, a one-off repair for a specific machine whose service
   names had been mangled.

Both are recorded here as documentation rather than reimplemented.
"""

import glob
import glob
import logging
import os
import shutil
import subprocess
import sys

from .registry import register_command

LAUNCHD_LABEL = "com.wireguard.wg0"
LAUNCHD_PLIST = f"/Library/LaunchDaemons/{LAUNCHD_LABEL}.plist"
WG_CONFIG = "/opt/homebrew/etc/wireguard/wg0.conf"
WG_LOG_GLOB = "/Library/Logs/com.wireguard.wg0.*.log"

# launchd plist — giữ nguyên nội dung từ bash, chỉ đổi cách sinh.
PLIST_TEMPLATE = """\
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.wireguard.wg0</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/wg-quick</string>
        <string>up</string>
        <string>wg0</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>WG_QUICK_DNS_SKIP</key>
        <string>1</string>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Library/Logs/com.wireguard.wg0.out.log</string>
    <key>StandardErrorPath</key>
    <string>/Library/Logs/com.wireguard.wg0.err.log</string>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>PathState</key>
        <dict>
            <key>/opt/homebrew/etc/wireguard/wg0.conf</key>
            <true/>
        </dict>
        <key>AfterInitialDemand</key>
        <true/>
    </dict>

    <key>WatchPaths</key>
    <array>
        <string>/opt/homebrew/etc/wireguard/wg0.conf</string>
    </array>

    <key>ThrottleInterval</key>
    <integer>5</integer>

    <key>StartInterval</key>
    <integer>60</integer>
</dict>
</plist>
"""


def _require_macos():
    if sys.platform != "darwin":
        logging.error("Nhóm lệnh này chỉ hỗ trợ macOS")
        return False
    return True


def _run(cmd, check=True):
    """Run a command, returning CompletedProcess or None on failure."""
    try:
        return subprocess.run(cmd, capture_output=True, text=True, check=check)
    except FileNotFoundError:
        logging.error("Không tìm thấy lệnh: %s", cmd[0])
        return None
    except subprocess.CalledProcessError as e:
        logging.error("%s thất bại: %s", " ".join(cmd), e.stderr.strip())
        return None


def _which(name):
    return shutil.which(name)


@register_command
def d_wg_status():
    """
    Hiển thị trạng thái WireGuard (macOS).
    Usage: ductn wg:status
    """
    if not _require_macos():
        return

    if not _which("wg"):
        print("WireGuard chưa được cài. Chạy: ductn wg:install")
        return

    result = _run(["wg", "show"], check=False)
    if result and result.stdout:
        print(result.stdout, end="")


@register_command
def d_wg_config():
    """
    In nội dung cấu hình WireGuard (macOS).
    Usage: ductn wg:config
    """
    if not _require_macos():
        return

    if not os.path.isfile(WG_CONFIG):
        print(f"Không tìm thấy cấu hình: {WG_CONFIG}")
        return

    try:
        with open(WG_CONFIG, "r", encoding="utf-8") as f:
            print(f.read(), end="")
    except OSError as e:
        logging.error("Không đọc được %s: %s", WG_CONFIG, e)


@register_command
def d_wg_install():
    """
    Cài wireguard-tools qua Homebrew (macOS).
    Usage: ductn wg:install
    """
    if not _require_macos():
        return

    if not _which("brew"):
        logging.error("Chưa có Homebrew. Xem https://brew.sh")
        return

    if _which("wg"):
        logging.info("wireguard-tools đã được cài")
        return

    _run(["brew", "install", "wireguard-tools"])
    logging.info("Đã cài wireguard-tools")


@register_command
def d_wg_log(args=None):
    """
    Theo dõi log WireGuard (macOS).
    Usage: ductn wg:log

    Bash gốc chạy `tail -f` (chặn cho tới Ctrl-C). Giữ nguyên hành vi.
    """
    if not _require_macos():
        return

    paths = sorted(glob.glob(WG_LOG_GLOB))
    if not paths:
        logging.error("Không có file log nào khớp %s", WG_LOG_GLOB)
        return

    try:
        subprocess.run(["tail", "-f"] + paths, check=False)
    except FileNotFoundError:
        logging.error("Không tìm thấy lệnh tail")
    except KeyboardInterrupt:
        pass


@register_command
def d_wg_service_install():
    """
    Cài launchd service cho WireGuard (macOS).
    Usage: ductn wg:service:install

    Ghi plist vào /Library/LaunchDaemons rồi bootstrap service.
    """
    if not _require_macos():
        return

    from .system import _is_root as _root

    if not _root():
        logging.error("Cần quyền root (sudo)")
        return

    d_wg_install()

    try:
        with open(LAUNCHD_PLIST, "w", encoding="utf-8") as f:
            f.write(PLIST_TEMPLATE)
            os.chmod(LAUNCHD_PLIST, 0o644)
    except OSError as e:
        logging.error("Không ghi được %s: %s", LAUNCHD_PLIST, e)
        return

    logging.info("Đã ghi %s", LAUNCHD_PLIST)
    d_wg_service_start()


@register_command
def d_wg_service_start():
    """
    Khởi động WireGuard service (macOS).
    Usage: ductn wg:service:start
    """
    if not _require_macos():
        return

    if not os.path.isfile(LAUNCHD_PLIST):
        logging.error("Chưa có plist. Chạy trước: ductn wg:service:install")
        return

    # bootstrap (10.13+), rồi enable để tự chạy khi reboot.
    _run(["launchctl", "bootstrap", "system", LAUNCHD_PLIST], check=False)
    _run(["launchctl", "enable", f"system/{LAUNCHD_LABEL}"], check=False)
    logging.info("WireGuard service đã start")


@register_command
def d_wg_service_stop():
    """
    Dừng WireGuard service (macOS).
    Usage: ductn wg:service:stop

    Bash gốc gọi thêm `d_dns:set` (không tham số) sau khi bootout để trả DNS
    về DHCP — nếu không, DNS trỏ vào resolver nội bộ của tunnel đã tắt và
    máy mất phân giải tên.
    """
    if not _require_macos():
        return

    _run(["launchctl", "bootout", "system", LAUNCHD_PLIST], check=False)

    from .dns import d_dns_set

    d_dns_set()
    logging.info("WireGuard service đã stop")


@register_command
def d_wg_service_restart():
    """
    Khởi động lại WireGuard service (macOS).
    Usage: ductn wg:service:restart
    """
    if not _require_macos():
        return

    d_wg_service_stop()
    d_wg_service_start()
