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
        logging.error(f"Loi go {package}: {e}")


def _apt_install(package: str):
    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", package]
        )
    except subprocess.CalledProcessError as e:
        logging.error(f"Loi cai {package}: {e}")


@register_command("vpn:wireguard:is_exist")
def d_vpn_wireguard_is_exist():
    """Kiem tra WireGuard da duoc cai dat chua."""
    if _wg_installed():
        print("1")
    else:
        print("0")


@register_command
def d_vpn_wireguard_install(args=None):
    """Cai dat WireGuard, go OpenVPN."""
    if not _is_root():
        logging.error("Can quyen root (sudo)")
        return

    _apt_remove("openvpn")
    _apt_install("wireguard")
    _apt_install("resolvconf")
    logging.info("WireGuard da duoc cai dat")


@register_command
def d_vpn_wireguard_keygen():
    """Tao WireGuard server keys (private + public)."""
    if not _is_root():
        logging.error("Can quyen root (sudo)")
        return

    os.makedirs(WIREGUARD_KEYDIR, exist_ok=True)
    os.chmod(WIREGUARD_KEYDIR, 0o755)

    private_key_path = os.path.join(WIREGUARD_KEYDIR, "server_private.key")
    public_key_path = os.path.join(WIREGUARD_KEYDIR, "server_public.key")

    for path in [private_key_path, public_key_path]:
        if not os.path.exists(path):
            open(path, "a").close()

    with open(private_key_path, "r") as f:
        private_key = f.read().strip()

    if not private_key:
        result = subprocess.run(
            ["wg", "genkey"], capture_output=True, text=True, check=True
        )
        private_key = result.stdout.strip()
        with open(private_key_path, "w") as f:
            f.write(private_key + "\n")

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

    os.chmod(WIREGUARD_KEYDIR, 0o755)
    for path in [private_key_path, public_key_path]:
        os.chmod(path, 0o644)

    print(private_key)
    print(public_key)


@register_command
def d_vpn_wireguard_reload():
    """Reload WireGuard configuration."""
    if not _is_root():
        logging.error("Can quyen root (sudo)")
        return

    try:
        subprocess.run(
            ["wg-quick", "down", WIREGUARD_IFACE],
            capture_output=True,
        )
        subprocess.check_call(
            ["systemctl", "stop", f"wg-quick@{WIREGUARD_IFACE}"]
        )
    except subprocess.CalledProcessError:
        pass

    # Read config from local file if exists
    wg0_config = ""
    if os.path.exists(WIREGUARD_CONFIG):
        with open(WIREGUARD_CONFIG, "r") as f:
            wg0_config = f.read().strip()

    if not wg0_config:
        subprocess.check_call(
            ["systemctl", "disable", f"wg-quick@{WIREGUARD_IFACE}"]
        )
        logging.info("WireGuard config rong, da disable service")
        return

    with open(WIREGUARD_CONFIG, "w") as f:
        f.write(wg0_config)

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
        pass

    logging.info("WireGuard da reload")



@register_command
def d_vpn_wireguard_stop():
    """Dừng WireGuard VPN service."""
    import sys
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
            logging.error(f"Khong the dung WireGuard tren macOS: {e.stderr.strip()}")
    elif os.path.exists("/bin/systemctl") or os.path.exists("/usr/bin/systemctl"):
        try:
            subprocess.run(
                ["systemctl", "stop", f"wg-quick@{WIREGUARD_IFACE}"],
                check=True,
                capture_output=True,
                text=True,
            )
            logging.info("WireGuard service stopped (Linux)")
        except subprocess.CalledProcessError as e:
            logging.error(f"Khong the dung WireGuard tren Linux: {e.stderr.strip()}")
    else:
        logging.error("Khong nhan dien duoc init system de dung WireGuard")


@register_command
def d_vpn_openvpn_uninstall():
    """Go OpenVPN."""
    if not _is_root():
        logging.error("Can quyen root (sudo)")
        return

    _apt_remove("openvpn")
    logging.info("OpenVPN da duoc go")


@register_command
def d_vpn_type():
    """Xac dinh loai VPN (client/server/none) dua theo domain."""
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
    """Tao example WireGuard config (server + clients)."""
    print("# WireGuard example config")
    print("# Su dung vpn:wireguard:keygen de tao keys")
    print(f"# Interface: {WIREGUARD_IFACE}")
    print(f"# Port: {WIREGUARD_PORT}")
