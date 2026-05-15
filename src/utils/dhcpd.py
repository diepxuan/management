#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root

DHCPD_CONF = "/etc/dhcp/dhcpd.conf"


@register_command
def d_dhcp_setup():
    """Cài đặt và cấu hình DHCP server."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", "isc-dhcp-server"]
        )
        logging.info("ISC DHCP Server đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài DHCP: {e}")


@register_command
def d_dhcp_config():
    """Cấu hình DHCP server."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    config = """# DHCP Server Configuration
default-lease-time 600;
max-lease-time 7200;

subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.100 192.168.1.200;
    option routers 192.168.1.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
"""

    os.makedirs(os.path.dirname(DHCPD_CONF), exist_ok=True)
    with open(DHCPD_CONF, "w") as f:
        f.write(config)

    logging.info("Đã ghi DHCP config")
