#!/usr/bin/env python3
"""SSL certificate management commands migrated from legacy bash.

The module preserves the original command surface from `src/var/lib/ssl.sh`:
`ssl:install`, `ssl:configure`, `ssl:setup`, `ssl:certbot`, `ssl:pull`,
`ssl:push`, and `ssl:upload`.
"""

import logging
import os
import shutil
import subprocess
from typing import Iterable

from .registry import register_command
from .system import _is_root

CLFR_ACCESS = "/etc/ductn/cloudflare"
CERTBOT_EMAIL = "caothu91@gmail.com"
LE_BASE = "/etc/letsencrypt/live"
DEFAULT_CERT_DOMAIN = "diepxuan.com"
CERT_FILES = ["cert.pem", "chain.pem", "fullchain.pem", "privkey.pem"]
DEFAULT_SETUP_GROUPS = [
    ["diepxuan.com", "*.diepxuan.com"],
    ["vps.diepxuan.com", "*.vps.diepxuan.com"],
]


def _certbot_installed() -> bool:
    """Return True when certbot is available in PATH."""
    return shutil.which("certbot") is not None


def _check_cloudflare_credentials() -> bool:
    """Validate Cloudflare credentials file used by certbot DNS challenge."""
    if not os.path.exists(CLFR_ACCESS):
        logging.error(f"Không tìm thấy Cloudflare credentials: {CLFR_ACCESS}")
        return False
    return True


def _normalize_domains(args: Iterable[str] | None) -> list[str]:
    """Normalize CLI domain arguments, accepting comma-separated legacy values."""
    domains: list[str] = []
    for arg in args or []:
        for item in str(arg).split(","):
            domain = item.strip()
            if domain:
                domains.append(domain)
    return domains


def _build_certbot_command(domains: list[str]) -> list[str]:
    """Build certbot command using Cloudflare DNS credentials."""
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
    return cmd


def _require_root() -> bool:
    """Log an error and return False when command needs root privileges."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return False
    return True


def _run_certbot(domains: list[str]) -> None:
    """Run certbot for one certificate domain group."""
    if not domains:
        logging.error("Cần truyền domain vào command")
        return
    if not _check_cloudflare_credentials():
        return

    os.chmod(CLFR_ACCESS, 0o600)
    subprocess.run(_build_certbot_command(domains), check=True)
    logging.info("Certbot hoàn tất thành công: %s", ", ".join(domains))


@register_command
def d_ssl_install() -> None:
    """Cài certbot và plugin Cloudflare DNS."""
    if not _require_root():
        return

    commands = [
        ["apt", "install", "software-properties-common", "-y", "--purge", "--auto-remove"],
        ["apt", "update"],
        ["apt", "install", "-y", "--purge", "--auto-remove", "python3-pip"],
        [
            "apt",
            "install",
            "-y",
            "--purge",
            "--auto-remove",
            "certbot",
            "python3-certbot-dns-cloudflare",
        ],
    ]
    for command in commands:
        subprocess.check_call(command)
    logging.info("certbot và plugin Cloudflare DNS đã được cài đặt")


@register_command
def d_ssl_configure() -> None:
    """Configure SSL bằng Cloudflare credentials và default domains."""
    if not _require_root():
        return
    if not _check_cloudflare_credentials():
        return
    d_ssl_setup()


@register_command
def d_ssl_setup(args: list[str] | None = None) -> None:
    """Setup SSL certificates và restart apache2."""
    if not _require_root():
        return

    domains = _normalize_domains(args)
    if domains:
        _run_certbot(domains)
    else:
        for domain_group in DEFAULT_SETUP_GROUPS:
            _run_certbot(domain_group)

    try:
        subprocess.check_call(["service", "apache2", "restart"])
        logging.info("Apache2 đã restart")
    except subprocess.CalledProcessError as exc:
        logging.warning("Không thể restart apache2: %s", exc)


@register_command
def d_ssl_certbot(args: list[str] | None = None) -> None:
    """Chạy certbot cho domain truyền vào, hỗ trợ danh sách cách nhau bằng dấu phẩy."""
    if not _require_root():
        return

    domains = _normalize_domains(args)
    if not domains:
        logging.error("Usage: ductn ssl:certbot <domain>[,<domain>] [...]")
        return
    _run_certbot(domains)


def _parse_remote_and_domain(args: list[str] | None) -> tuple[str | None, str]:
    """Parse legacy-compatible SSL copy args.

    Legacy bash accepted only the remote host and always used diepxuan.com.
    Python also supports an optional explicit domain with two args:
    `ductn ssl:push <remote_host> <domain>`.
    """
    values = list(args or [])
    if not values:
        return None, DEFAULT_CERT_DOMAIN
    remote_host = values[0]
    domain = values[1] if len(values) > 1 else DEFAULT_CERT_DOMAIN
    return remote_host, domain


def _local_cert_path(domain: str, filename: str) -> str:
    """Return local Let's Encrypt certificate path."""
    return f"{LE_BASE}/{domain}/{filename}"


@register_command
def d_ssl_pull(args: list[str] | None = None) -> None:
    """Pull SSL certificates từ remote server: ductn ssl:pull <remote_host> [domain]."""
    if not _require_root():
        return

    remote_host, domain = _parse_remote_and_domain(args)
    if not remote_host:
        logging.error("Usage: ductn ssl:pull <remote_host> [domain]")
        return

    os.makedirs(f"{LE_BASE}/{domain}/", exist_ok=True)
    for filename in CERT_FILES:
        local_path = _local_cert_path(domain, filename)
        remote_path = f"{LE_BASE}/{domain}/{filename}"
        result = subprocess.run(
            ["ssh", remote_host, f"sudo cat {remote_path}"],
            check=True,
            capture_output=True,
            text=True,
        )
        with open(local_path, "w") as cert_file:
            cert_file.write(result.stdout)
        logging.info("Pull %s từ %s thành công", filename, remote_host)


@register_command
def d_ssl_push(args: list[str] | None = None) -> None:
    """Push SSL certificates tới remote server: ductn ssl:push <remote_host> [domain]."""
    if not _require_root():
        return

    remote_host, domain = _parse_remote_and_domain(args)
    if not remote_host:
        logging.error("Usage: ductn ssl:push <remote_host> [domain]")
        return

    for filename in CERT_FILES:
        local_path = _local_cert_path(domain, filename)
        remote_path = f"{LE_BASE}/{domain}/{filename}"
        command = f'sudo cat {local_path} | ssh {remote_host} "sudo tee {remote_path}"'
        subprocess.run(command, shell=True, check=True)
        logging.info("Push %s tới %s thành công", filename, remote_host)


@register_command
def d_ssl_upload(args: list[str] | None = None) -> None:
    """Upload SSL certificates tới remote server; alias của ssl:push."""
    d_ssl_push(args)
