#!/usr/bin/env python3

import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_server_install():
    """Cài đặt full server (Apache, PHP, MySQL, DNS, etc)."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    logging.info("Bắt đầu cài đặt server...")

    # Install core packages
    packages = [
        "apache2", "php", "mysql-server", "bind9",
        "certbot", "python3-certbot-dns-cloudflare",
        "git", "curl", "wget", "unzip", "jq",
    ]

    try:
        subprocess.check_call(["apt-get", "update"])
        subprocess.check_call(
            ["apt-get", "install", "-y"] + packages
        )
        logging.info("Server đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài đặt server: {e}")
