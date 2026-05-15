#!/usr/bin/env python3

import os
import subprocess
import logging
import shutil

from .registry import register_command
from .system import _is_root

WIREGUARD_IFACE = "wg0"
WIREGUARD_PORT = 17691
WIREGUARD_CONFIG = f"/etc/wireguard/{WIREGUARD_IFACE}.conf"
WIREGUARD_KEYDIR = "/etc/wireguard/keys"


def _wg_installed() -> bool:
    return shutil.which("wg") is not None


def _apt_remove(package: str):
    try:
        subprocess.check_call(
            ["apt-get", "remove", "-y", "--purge", "--auto-remove", package]
        )
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi gỡ {package}: {e}")


def _apt_install(package: str):
    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", package]
        )
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài {package}: {e}")


@register_command("vpn:wireguard:is_exist")
def d_vpn_wireguard_is_exist():
    """Kiểm tra WireGuard đã được cài đặt chưa."""
    if _wg_installed():
        print("1")
    else:
        print("0")


@register_command
def d_vpn_wireguard_install(args=None):
    """Cài đặt WireGuard, gỡ OpenVPN."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    _apt_remove("openvpn")
    _apt_install("wireguard")
    _apt_install("resolvconf")
    logging.info("WireGuard đã được cài đặt")


@register_command
def d_vpn_wireguard_keygen():
    """Tạo WireGuard server keys (private + public)."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    os.makedirs(WIREGUARD_KEYDIR, exist_ok=True)
    os.chmod(WIREGUARD_KEYDIR, 0o755)

    private_key_path = os.path.join(WIREGUARD_KEYDIR, "server_private.key")
    public_key_path = os.path.join(WIREGUARD_KEYDIR, "server_public.key")

    # Tạo file nếu chưa có
    for path in [private_key_path, public_key_path]:
        if not os.path.exists(path):
            open(path, "a").close()

    # Đọc private key hiện tại
    with open(private_key_path, "r") as f:
        private_key = f.read().strip()

    if not private_key:
        # Sinh key mới
        result = subprocess.run(
            ["wg", "genkey"], capture_output=True, text=True, check=True
        )
        private_key = result.stdout.strip()
        with open(private_key_path, "w") as f:
            f.write(private_key + "\n")

    # Đọc hoặc sinh public key
    with open(public_key_path, "r") as f:
        public_key = f.read().strip()

    if not public_key:
        result = subprocess.run(
            ["wg", "pubkey"],
            input=private_key,
            capture_output=True,
            text=True,
            check=True,
        )
        public_key = result.stdout.strip()
        with open(public_key_path, "w") as f:
            f.write(public_key + "\n")

    # Set permissions
    os.chmod(WIREGUARD_KEYDIR, 0o755)
    for path in [private_key_path, public_key_path]:
        os.chmod(path, 0o644)

    print(private_key)
    print(public_key)


@register_command
def d_vpn_wireguard_reload():
    """Reload WireGuard configuration từ env."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    # Stop hiện tại
    try:
        subprocess.run(
            ["wg-quick", "down", WIREGUARD_IFACE],
            capture_output=True,
        )
        subprocess.check_call(
            ["systemctl", "stop", f"wg-quick@{WIREGUARD_IFACE}"]
        )
    except subprocess.CalledProcessError:
        pass  # Có thể chưa chạy

    # Stop nếu config rỗng
    try:
        from . import env_config
        wg0_config = env_config._sys_env_vpn()
    except Exception:
        wg0_config = ""

    if not wg0_config:
        subprocess.check_call(
            ["systemctl", "disable", f"wg-quick@{WIREGUARD_IFACE}"]
        )
        logging.info("WireGuard config rỗng, đã disable service")
        return

    # Ghi config mới
    with open(WIREGUARD_CONFIG, "w") as f:
        f.write(wg0_config)

    # Restart
    subprocess.check_call(
        ["systemctl", "enable", f"wg-quick@{WIREGUARD_IFACE}"]
    )
    subprocess.check_call(
        ["systemctl", "restart", f"wg-quick@{WIREGUARD_IFACE}"]
    )
    try:
        subprocess.check_call(
            ["wg-quick", "up", WIREGUARD_IFACE]
        )
    except subprocess.CalledProcessError:
        pass  # Có thể đã up rồi

    logging.info("WireGuard đã reload")


@register_command
def d_vpn_openvpn_uninstall():
    """Gỡ OpenVPN."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    _apt_remove("openvpn")
    logging.info("OpenVPN đã được gỡ")


@register_command
def d_vpn_type():
    """Xác định loại VPN (client/server/none) dựa theo domain."""
    try:
        from . import host
        domain = host._host_domain()
    except Exception:
        domain = ""

    if domain == "diepxuan.com":
        print("client")
    elif domain == "vpn":
        print("server")
    else:
        print("none")


@register_command
def d_vpn_wireguard_example():
    """Tạo example WireGuard config (server + clients)."""
    print("# WireGuard example config")
    print("# Sử dụng vpn:wireguard:keygen để tạo keys")
    print(f"# Interface: {WIREGUARD_IFACE}")
    print(f"# Port: {WIREGUARD_PORT}")
