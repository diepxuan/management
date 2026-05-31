#!/usr/bin/env python3

import re
import socket
import subprocess
from urllib import request

from .registry import register_command
from . import _is_root


def _is_valid_ipv4(ip: str) -> bool:
    """Validate IPv4 format."""
    return bool(re.match(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$', ip))


def _ip_wan() -> str:
    """Get public IP address via multiple fallback sources."""
    # Method 1: dig via Google DNS (preferred, uses system dig if available)
    try:
        result = subprocess.run(
            ["dig", "-4", "@ns1.google.com", "-t", "txt", "o-o.myaddr.l.google.com", "+short"],
            capture_output=True, text=True, timeout=5
        )
        ip = result.stdout.strip().strip('"')
        if _is_valid_ipv4(ip):
            return ip
    except (subprocess.SubprocessError, FileNotFoundError, OSError):
        pass

    # Method 2: dig via OpenDNS
    try:
        result = subprocess.run(
            ["dig", "-4", "@resolver1.opendns.com", "-t", "A", "myip.opendns.com", "+short"],
            capture_output=True, text=True, timeout=5
        )
        ip = result.stdout.strip()
        if _is_valid_ipv4(ip):
            return ip
    except (subprocess.SubprocessError, FileNotFoundError, OSError):
        pass

    # Method 3: HTTP fallbacks
    for url in [
        "https://api.ipify.org",
        "https://ipinfo.io/ip",
        "https://checkip.amazonaws.com",
        "https://icanhazip.com",
    ]:
        try:
            with request.urlopen(url, timeout=5) as response:
                ip = response.read().decode("utf-8").strip()
                if _is_valid_ipv4(ip):
                    return ip
        except Exception:
            continue

    return "0.0.0.0"


def _ip_local() -> str:
    """Get the local IP via default route interface."""
    if _is_root() is False:
        # Non-root: use socket method
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
                s.connect(("8.8.8.8", 80))
                return s.getsockname()[0]
        except Exception:
            return ""

    # Root: get IP from default route interface
    try:
        result = subprocess.run(
            ["ip", "route", "show", "default"],
            capture_output=True, text=True, check=True
        )
        match = re.search(r"dev\s+(\S+)", result.stdout)
        if not match:
            return ""
        iface = match.group(1)
    except (subprocess.SubprocessError, FileNotFoundError):
        return ""

    try:
        result = subprocess.run(
            ["ip", "addr", "show", iface],
            capture_output=True, text=True, check=True
        )
        for line in result.stdout.splitlines():
            if "inet " in line:
                # Extract IP/CIDR, then strip CIDR
                parts = line.strip().split()
                for i, part in enumerate(parts):
                    if part == "inet" and i + 1 < len(parts):
                        return parts[i + 1].split("/")[0]
    except (subprocess.SubprocessError, FileNotFoundError):
        pass

    return ""


def _ip_locals() -> list:
    """Get all IPv4 addresses from UP interfaces, excluding loopback."""
    ips = []
    try:
        result = subprocess.run(
            ["ip", "-4", "addr", "show"],
            capture_output=True, text=True, check=True
        )
        current_if = None
        for line in result.stdout.splitlines():
            # Interface line: "2: eth0: <...state UP..."
            if line[0:1].isdigit():
                match = re.match(r"^\d+:\s+(\S+):", line)
                if match:
                    current_if = match.group(1).split("@")[0]
                is_up = "state UP" in line
                if not is_up:
                    current_if = None
            elif current_if and "inet " in line:
                parts = line.strip().split()
                for i, part in enumerate(parts):
                    if part == "inet" and i + 1 < len(parts):
                        ip = parts[i + 1].split("/")[0]
                        if not ip.startswith("127.") and ip not in ips:
                            ips.append(ip)
    except (subprocess.SubprocessError, FileNotFoundError):
        pass
    return ips


@register_command
def d_ip_wan():
    """Get public IP address"""
    print(_ip_wan())


@register_command
def d_ip_local():
    """Get local IP address"""
    print(_ip_local())


@register_command
def d_ip_locals():
    """Get all local IP addresses"""
    for ip in _ip_locals():
        print(ip)
