#!/usr/bin/env python3
# shellcheck disable=SC2034,SC2154,SC1090,SC1091

import logging
import socket
import sys
from typing import Optional
from .registry import register_command
from .init_action import call_init_action, register_init_action
import subprocess

DEFAULT_DOMAIN = "diepxuan.corp"


@register_init_action
def _launchd_host_name():
    try:
        name = socket.gethostname().split(".", 1)[0]
        if not name:
            try:
                name = (
                    subprocess.check_output(
                        ["scutil", "--get", "ComputerName"],
                        text=True,
                    )
                    .decode()
                    .strip()
                )
            except Exception:
                pass

        if not name:
            name = "unknown-host"

        return name
    except Exception as e:
        logging.error(f"Không thể lấy hostname: {e}")
        return "unknown-host"


@register_init_action
def _systemd_host_name():
    try:
        return socket.gethostname().split(".", 1)[0]
    except Exception as e:
        logging.error(f"Không thể lấy hostname: {e}")
        return "unknown-host"


def _host_name():
    """Trả về tên hostname ngắn của máy."""
    return call_init_action("host_name")


@register_command
def d_host_name():
    """In tên hostname ngắn của máy."""
    print(_host_name())


def _looks_like_ipv4(s: str) -> bool:
    """True nếu ``s`` là một địa chỉ IPv4 hợp lệ (4 octet 0-255).

    Dùng để loại bỏ FQDN giả do Proxmox sinh ra trong /etc/hosts
    (ví dụ ``postgresql.192.168.1.1``) — phần "domain" đó không thể là
    zone name của DNS.
    """
    if not s:
        return False
    parts = s.split(".")
    if len(parts) != 4:
        return False
    for part in parts:
        if not part.isdigit():
            return False
        if not 0 <= int(part) <= 255:
            return False
    return True


def _domain_from_resolv_conf() -> Optional[str]:
    """
    Đọc directive ``search`` đầu tiên trong /etc/resolv.conf.

    Đây là nguồn đáng tin nhất trên Linux: resolver dùng nó để mở rộng
    hostname một nhãn, nên giá trị khớp với zone name mà internal DNS API
    mong đợi. Trên host có /etc/hosts kiểu Proxmox
    (``postgresql.192.168.1.1``), parse socket.getfqdn() cho ra rác, còn
    search directive vẫn phản ánh zone thật.

    Trả về None nếu không có search directive hoặc file không đọc được.
    """
    try:
        with open("/etc/resolv.conf", "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or line.startswith(";"):
                    continue
                # Bỏ comment inline.
                if "#" in line:
                    line = line.split("#", 1)[0].strip()
                    if not line:
                        continue
                parts = line.split(None, 1)
                if len(parts) != 2:
                    continue
                keyword, value = parts[0].lower(), parts[1].strip()
                if keyword == "search" and value:
                    # res_init(3) lấy search domain đầu tiên làm primary.
                    return value.split()[0]
    except OSError:
        pass
    return None


def _host_domain():
    """
    Trả về tên domain của máy.

    Thứ tự ưu tiên:
      1. ``search`` directive trong /etc/resolv.conf — đáng tin nhất, khớp
         với zone name mà internal DNS API mong đợi.
      2. Bóc hostname khỏi ``socket.getfqdn()`` — fallback cũ, dùng được
         khi host có FQDN thật (trong /etc/hosts hoặc DNS).
         Ứng viên nào trông như IPv4 (``192.168.1.1``) sẽ bị loại.
      3. ``DEFAULT_DOMAIN`` (``diepxuan.corp``).

    Không bao giờ trả về chuỗi rỗng — caller dựa vào giá trị non-empty
    để tra zone trên DNS API.
    """
    # 1. /etc/resolv.conf search domain.
    resolv_domain = _domain_from_resolv_conf()
    if resolv_domain:
        return resolv_domain

    # 2. Parse từ socket.getfqdn().
    try:
        fullname = socket.getfqdn()
        if ":" in fullname or "ip6.arpa" in fullname:  # IPv6
            return DEFAULT_DOMAIN

        hostname = socket.gethostname()
        if fullname.startswith(hostname + ".") and len(fullname) > len(hostname):
            candidate = fullname[len(hostname) + 1 :]
            # Loại FQDN giả dạng IP (Proxmox: postgresql.192.168.1.1).
            if not _looks_like_ipv4(candidate):
                return candidate

        return DEFAULT_DOMAIN
    except Exception:
        return DEFAULT_DOMAIN


@register_command
def d_host_domain():
    """In tên domain của máy."""
    print(_host_domain())


@register_init_action
def _launchd_host_fullname():
    return _host_name() + "." + _host_domain()


@register_init_action
def _systemd_host_fullname():
    try:
        return socket.getfqdn()
    except Exception as e:
        return _host_name() + "." + _host_domain()


def _host_fullname():
    """Trả về tên hostname đầy đủ (FQDN) của máy."""
    return call_init_action("host_fullname")


@register_command
def d_host_fullname():
    """In tên hostname đầy đủ (FQDN) của máy."""
    print(_host_fullname())
