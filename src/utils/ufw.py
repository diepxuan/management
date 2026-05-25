#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_ufw_disable():
    """Tắt UFW firewall."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["ufw", "disable"])
        logging.info("UFW đã được tắt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi tắt UFW: {e}")


@register_command
def d_ufw_geoip_uninstall():
    """Gỡ GeoIP rules khỏi UFW."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["ufw", "delete", "allow", "from", "any", "to", "any", "comment", "GeoIP"])
        logging.info("Đã gỡ GeoIP rules")
    except subprocess.CalledProcessError:
        logging.warning("Không có GeoIP rules để gỡ")


@register_command("ufw:geoip:allowCloudflare")
def d_ufw_geoip_allow_cloudflare():
    """Cho phép Cloudflare IPs qua UFW."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        import requests
        # Lấy Cloudflare IPs
        for url in ["https://www.cloudflare.com/ips-v4", "https://www.cloudflare.com/ips-v6"]:
            resp = requests.get(url, timeout=10)
            for line in resp.text.strip().split("\n"):
                line = line.strip()
                if line:
                    subprocess.run(
                        ["ufw", "allow", "from", line, "to", "any", "port", "80,443", "proto", "tcp", "comment", "Cloudflare"],
                        capture_output=True,
                    )
        logging.info("Đã thêm Cloudflare IPs vào UFW")
    except Exception as e:
        logging.error(f"Lỗi thêm Cloudflare IPs: {e}")


@register_command
def d_ufw_fail2ban_uninstall():
    """Gỡ fail2ban."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "remove", "-y", "--purge", "--auto-remove", "fail2ban"]
        )
        logging.info("fail2ban đã được gỡ")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi gỡ fail2ban: {e}")


@register_command
def d_ufw_iptables_uninstall():
    """Gỡ iptables rules."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["iptables", "-F"])
        subprocess.check_call(["iptables", "-X"])
        subprocess.check_call(["iptables", "-t", "nat", "-F"])
        subprocess.check_call(["iptables", "-t", "nat", "-X"])
        subprocess.check_call(["iptables", "-t", "mangle", "-F"])
        subprocess.check_call(["iptables", "-t", "mangle", "-X"])
        logging.info("Đã flush iptables rules")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi flush iptables: {e}")
