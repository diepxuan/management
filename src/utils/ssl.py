#!/usr/bin/env python3

import os
import shutil
import subprocess
import logging
import sys

from .registry import register_command
from .system import _is_root

CLFR_ACCESS = "/etc/ductn/cloudflare"
CERTBOT_EMAIL = "caothu91@gmail.com"
LE_BASE = "/etc/letsencrypt/live"


def _certbot_installed() -> bool:
    return shutil.which("certbot") is not None


def _ensure_certbot():
    if not _certbot_installed():
        logging.info("Cài đặt certbot và dependencies...")
        subprocess.check_call(
            [
                "apt-get",
                "install",
                "-y",
                "--purge",
                "--auto-remove",
                "certbot",
                "python3-certbot-dns-cloudflare",
            ]
        )


@register_command
def d_ssl_install():
    """Cài đặt certbot và Cloudflare DNS plugin."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    _ensure_certbot()
    logging.info("certbot đã được cài đặt")


def _check_cloudflare_credentials() -> bool:
    if not os.path.exists(CLFR_ACCESS):
        logging.error(f"Không tìm thấy Cloudflare credentials: {CLFR_ACCESS}")
        return False
    return True


def _run_certbot(domains: list[str]):
    if not _check_cloudflare_credentials():
        return

    os.chmod(CLFR_ACCESS, 0o600)

    cmd = [
        "certbot",
        "certonly",
        "--expand",
        "--keep-until-expiring",
        "--dns-cloudflare",
        "--dns-cloudflare-credentials",
        CLFR_ACCESS,
        "--agree-tos",
        "--email",
        CERTBOT_EMAIL,
        "--eff-email",
    ]

    for domain in domains:
        cmd.extend(["-d", domain])

    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        logging.info("Certbot hoàn tất thành công")
        if result.stdout:
            logging.info(result.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(f"Certbot thất bại: {e.stderr}")
        raise


@register_command
def d_ssl_setup(domains=None):
    """
    Setup SSL certificates cho các domain.
    Sử dụng certbot với Cloudflare DNS challenge.
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    _ensure_certbot()

    if domains:
        domain_list = domains
    else:
        # Default domains nếu không truyền vào
        domain_list = [
            "diepxuan.com,*.diepxuan.com".split(","),
            "vps.diepxuan.com,*.vps.diepxuan.com".split(","),
        ]
        # Flatten list
        domain_list = [d.strip() for sublist in domain_list for d in sublist]

    for domain in domain_list:
        _run_certbot([domain])

    # Restart apache2
    try:
        subprocess.check_call(["systemctl", "restart", "apache2"])
        logging.info("Apache2 đã restart")
    except subprocess.CalledProcessError:
        logging.warning("Không thể restart apache2")


@register_command
def d_ssl_configure():
    """Configure SSL (gọi ssl:setup với default domains)."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not _check_cloudflare_credentials():
        return

    d_ssl_setup()


@register_command
def d_ssl_certbot(domains=None):
    """
    Chạy certbot trực tiếp cho danh sách domain.
    Usage: ductn ssl:certbot example.com www.example.com
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if domains:
        # domains là list từ extra_args
        _run_certbot(domains)
    else:
        logging.error("Cần truyền domain vào command")


def _copy_cert_via_ssh(
    domain: str,
    remote_host: str,
    cert_files: list[str] = None,
    direction: str = "push",
):
    if cert_files is None:
        cert_files = ["cert.pem", "chain.pem", "fullchain.pem", "privkey.pem"]

    remote_path = f"/etc/letsencrypt/live/{domain}/"

    for filename in cert_files:
        local_path = f"{LE_BASE}/{domain}/{filename}"
        if not os.path.exists(local_path):
            logging.warning(f"File không tồn tại: {local_path}")
            continue

        if direction == "pull":
            cmd = f'ssh {remote_host} "sudo cat {remote_path}{filename}"'
            try:
                result = subprocess.run(
                    cmd,
                    shell=True,
                    check=True,
                    capture_output=True,
                    text=True,
                )
                os.makedirs(os.path.dirname(local_path), exist_ok=True)
                with open(local_path, "w") as f:
                    f.write(result.stdout)
                logging.info(f"Pull {filename} từ {remote_host} thành công")
            except subprocess.CalledProcessError as e:
                logging.error(f"Lỗi pull {filename}: {e.stderr}")
        else:  # push
            cmd = f'sudo cat {local_path} | ssh {remote_host} "sudo tee {remote_path}{filename}"'
            try:
                subprocess.run(cmd, shell=True, check=True)
                logging.info(f"Push {filename} tới {remote_host} thành công")
            except subprocess.CalledProcessError as e:
                logging.error(f"Lỗi push {filename}: {e}")


@register_command
def d_ssl_pull(args=None):
    """
    Pull SSL certificates từ remote server.
    Usage: ductn ssl:pull domain.com remote_host
    """
    if not args:
        logging.error("Usage: ductn ssl:pull <domain> <remote_host>")
        return

    domain = args[0] if len(args) > 0 else "diepxuan.com"
    remote_host = args[1] if len(args) > 1 else None

    if not remote_host:
        logging.error("Cần truyền remote_host")
        return

    _copy_cert_via_ssh(domain, remote_host, direction="pull")


@register_command
def d_ssl_push(args=None):
    """
    Push SSL certificates tới remote server.
    Usage: ductn ssl:push domain.com remote_host
    """
    if not args:
        logging.error("Usage: ductn ssl:push <domain> <remote_host>")
        return

    domain = args[0] if len(args) > 0 else "diepxuan.com"
    remote_host = args[1] if len(args) > 1 else None

    if not remote_host:
        logging.error("Cần truyền remote_host")
        return

    _copy_cert_via_ssh(domain, remote_host, direction="push")


@register_command
def d_ssl_upload(args=None):
    """Upload SSL certificates tới remote (alias của ssl:push)."""
    d_ssl_push(args)
