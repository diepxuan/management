#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_ddns_bind9_install():
    """Cài đặt Bind9 DDNS server."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", "bind9", "bind9utils"]
        )
        logging.info("Bind9 DDNS đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài Bind9: {e}")


@register_command
def d_ddns_resolved():
    """Re-enable systemd-resolved."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        os.symlink(
            "/run/systemd/resolve/stub-resolv.conf",
            "/etc/resolv.conf",
            force=True,
        )
        subprocess.check_call(["systemctl", "enable", "systemd-resolved"])
        subprocess.check_call(["systemctl", "restart", "systemd-resolved"])
        logging.info("systemd-resolved đã được bật lại")
    except Exception as e:
        logging.error(f"Lỗi bật resolved: {e}")
