#!/usr/bin/env python3
"""SSL certificate management commands."""

from __future__ import annotations

import logging
import os
import shutil
import subprocess
from pathlib import Path
from typing import Iterable

from .registry import register_command
from .system import _is_root

CLFR_ACCESS = "/etc/ductn/cloudflare"
CERTBOT_EMAIL = "caothu91@gmail.com"
DEFAULT_SETUP_GROUPS = [
    ["diepxuan.com", "*.diepxuan.com"],
    ["vps.diepxuan.com", "*.vps.diepxuan.com"],
]
APACHE_VHOST_DIRS = [Path("/etc/apache2/sites-enabled"), Path("/etc/apache2/sites-available")]
NGINX_VHOST_DIRS = [Path("/etc/nginx/sites-enabled"), Path("/etc/nginx/conf.d")]


def _certbot_installed() -> bool:
    """Return True when certbot is available in PATH."""
    return shutil.which("certbot") is not None


def _check_cloudflare_credentials() -> bool:
    """Validate Cloudflare credentials file used by certbot DNS challenge."""
    if not os.path.exists(CLFR_ACCESS):
        logging.error("Không tìm thấy Cloudflare credentials: %s", CLFR_ACCESS)
        return False
    return True


def _normalize_domains(args: Iterable[str] | None) -> list[str]:
    """Normalize CLI domain arguments, accepting comma-separated values."""
    domains: list[str] = []
    for arg in args or []:
        for item in str(arg).split(","):
            domain = item.strip()
            if domain:
                domains.append(domain)
    return domains


def _is_wildcard_domain(domain: str) -> bool:
    return domain.startswith("*.")


def _service_installed(command: str) -> bool:
    return shutil.which(command) is not None


def _read_text(path: Path) -> str:
    try:
        return path.read_text(errors="ignore")
    except OSError:
        return ""


def _vhost_matches_domain(text: str, domain: str, server_directive: str) -> bool:
    """Return True if vhost config declares the requested domain."""
    if _is_wildcard_domain(domain):
        return False
    tokens = text.replace(";", " ").split()
    for index, token in enumerate(tokens):
        if token != server_directive:
            continue
        values: list[str] = []
        cursor = index + 1
        while cursor < len(tokens) and not tokens[cursor].startswith("-"):
            if tokens[cursor] in {"ServerName", "ServerAlias", "server_name"}:
                break
            values.append(tokens[cursor].strip())
            cursor += 1
        if domain in values:
            return True
    return False


def _has_matching_vhost(domains: list[str], dirs: list[Path], server_directive: str) -> bool:
    """Check all non-wildcard domains exist in Apache/Nginx vhost config."""
    plain_domains = [domain for domain in domains if not _is_wildcard_domain(domain)]
    if not plain_domains:
        return False

    configs: list[str] = []
    for directory in dirs:
        if not directory.exists():
            continue
        for path in directory.rglob("*"):
            if path.is_file():
                configs.append(_read_text(path))

    if not configs:
        return False

    for domain in plain_domains:
        if not any(_vhost_matches_domain(config, domain, server_directive) for config in configs):
            return False
    return True


def _select_certbot_mode(domains: list[str]) -> str:
    """Select apache/nginx integration when installed and vhost matches; fallback DNS."""
    if any(_is_wildcard_domain(domain) for domain in domains):
        return "dns-cloudflare"
    if _service_installed("apache2") and _has_matching_vhost(domains, APACHE_VHOST_DIRS, "ServerName"):
        return "apache"
    if _service_installed("nginx") and _has_matching_vhost(domains, NGINX_VHOST_DIRS, "server_name"):
        return "nginx"
    return "dns-cloudflare"


def _build_certbot_command(domains: list[str], mode: str | None = None) -> list[str]:
    """Build certbot command for apache/nginx integration or Cloudflare DNS."""
    selected_mode = mode or _select_certbot_mode(domains)
    cmd = ["certbot"]

    if selected_mode == "apache":
        cmd.append("--apache")
    elif selected_mode == "nginx":
        cmd.append("--nginx")
    else:
        cmd.extend([
            "certonly",
            "--dns-cloudflare",
            "--dns-cloudflare-credentials",
            CLFR_ACCESS,
        ])

    cmd.extend([
        "--expand",
        "--keep-until-expiring",
        "--agree-tos",
        "--email",
        CERTBOT_EMAIL,
        "--eff-email",
    ])
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

    mode = _select_certbot_mode(domains)
    if mode == "dns-cloudflare":
        if not _check_cloudflare_credentials():
            return
        os.chmod(CLFR_ACCESS, 0o600)

    logging.info("Certbot mode: %s for %s", mode, ", ".join(domains))
    subprocess.run(_build_certbot_command(domains, mode), check=True)
    logging.info("Certbot hoàn tất thành công: %s", ", ".join(domains))


@register_command
def d_ssl_install() -> None:
    """Cài certbot và plugin Apache/Nginx/Cloudflare DNS."""
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
            "python3-certbot-apache",
            "python3-certbot-nginx",
        ],
    ]
    for command in commands:
        subprocess.check_call(command)
    logging.info("certbot và plugin Apache/Nginx/Cloudflare DNS đã được cài đặt")


@register_command
def d_ssl_configure() -> None:
    """Configure SSL bằng certbot auto-integrate hoặc Cloudflare DNS fallback."""
    if not _require_root():
        return
    d_ssl_setup()


@register_command
def d_ssl_setup(args: list[str] | None = None) -> None:
    """Setup SSL certificates bằng Apache/Nginx integration hoặc Cloudflare DNS."""
    if not _require_root():
        return

    domains = _normalize_domains(args)
    if domains:
        _run_certbot(domains)
    else:
        for domain_group in DEFAULT_SETUP_GROUPS:
            _run_certbot(domain_group)


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
