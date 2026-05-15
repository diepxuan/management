#!/usr/bin/env python3

import os
import subprocess
import logging
import requests

from .registry import register_command
from .system import _is_root

TECHNITIUM_API = "http://localhost:53443/api"
TECHNITIUM_TOKEN_FILE = "/etc/ductn/technitium.token"


def _get_technitium_token():
    if os.path.exists(TECHNITIUM_TOKEN_FILE):
        with open(TECHNITIUM_TOKEN_FILE, "r") as f:
            return f.read().strip()
    return ""


@register_command
def d_dns_technitium_install():
    """Cài đặt Technitium DNS server."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", "dnsutils", "curl"]
        )
        # Technitium install script
        subprocess.run(
            "curl -sSL https://download.technitium.com/dns/install.sh | sudo bash",
            shell=True,
            check=True,
        )
        logging.info("Technitium DNS đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài Technitium DNS: {e}")


@register_command("dns:technitium:recordList")
def d_dns_technitium_record_list():
    """Liệt kê DNS records từ Technitium."""
    token = _get_technitium_token()
    if not token:
        logging.error("Không tìm thấy Technitium API token")
        return

    try:
        resp = requests.get(
            f"{TECHNITIUM_API}/zones/records/get",
            params={"token": token, "listZone": "true"},
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()
        if data.get("status") == "ok":
            records = data.get("response", {}).get("records", [])
            for rec in records:
                print(f"{rec.get('name')} {rec.get('type')} {rec.get('rData')}")
    except Exception as e:
        logging.error(f"Lỗi lấy DNS records: {e}")
