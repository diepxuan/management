#!/usr/bin/env python3

import sys
import subprocess
import logging
import os

from . import system_os
from .registry import register_command


@register_command
def d_wg_stop():
    """Dừng WireGuard VPN service."""
    if sys.platform == "darwin":
        cmd = [
            "sudo",
            "launchctl",
            "bootout",
            "system",
            "/Library/LaunchDaemons/com.wireguard.wg0.plist",
        ]
        try:
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            logging.info("WireGuard service stopped (macOS)")
        except subprocess.CalledProcessError as e:
            logging.error(f"Không thể dừng WireGuard trên macOS: {e.stderr.strip()}")
    elif os.path.exists("/bin/systemctl") or os.path.exists("/usr/bin/systemctl"):
        try:
            subprocess.run(
                ["systemctl", "stop", "wg-quick@wg0"],
                check=True,
                capture_output=True,
                text=True,
            )
            logging.info("WireGuard service stopped (Linux)")
        except subprocess.CalledProcessError as e:
            logging.error(f"Không thể dừng WireGuard trên Linux: {e.stderr.strip()}")
    else:
        logging.error("Không nhận diện được init system để dừng WireGuard")
