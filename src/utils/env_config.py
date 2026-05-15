#!/usr/bin/env python3

import os
import json
import logging
import subprocess

from .registry import register_command

ENV_CONFIG_DIR = "/etc/ductn/env"
ENV_CONFIG_FILE = f"{ENV_CONFIG_DIR}/config.json"


def _load_env_config():
    if os.path.exists(ENV_CONFIG_FILE):
        with open(ENV_CONFIG_FILE, "r") as f:
            return json.load(f)
    return {}


def _save_env_config(config):
    os.makedirs(ENV_CONFIG_DIR, exist_ok=True)
    with open(ENV_CONFIG_FILE, "w") as f:
        json.dump(config, f, indent=2)


def _sys_env_vpn():
    config = _load_env_config()
    return config.get("vpn", "")


@register_command
def d_env():
    """Hiển thị environment configuration."""
    config = _load_env_config()
    if config:
        print(json.dumps(config, indent=2))
    else:
        print("Environment configuration is empty")


@register_command
def d_env_domains():
    """Hiển thị domains trong environment config."""
    config = _load_env_config()
    domains = config.get("domains", [])
    for domain in domains:
        print(domain)


@register_command
def d_env_nat():
    """Hiển thị NAT configuration."""
    config = _load_env_config()
    nat = config.get("nat", {})
    if nat:
        print(json.dumps(nat, indent=2))


@register_command
def d_env_dhcp():
    """Hiển thị DHCP configuration."""
    config = _load_env_config()
    dhcp = config.get("dhcp", {})
    if dhcp:
        print(json.dumps(dhcp, indent=2))


@register_command
def d_env_vpn():
    """Hiển thị VPN configuration."""
    config = _load_env_config()
    vpn = config.get("vpn", "")
    if vpn:
        print(vpn)


@register_command
def d_env_csf():
    """Hiển thị CSF configuration."""
    config = _load_env_config()
    csf = config.get("csf", {})
    if csf:
        print(json.dumps(csf, indent=2))


def _sys_env_sync():
    """Đồng bộ environment configuration."""
    logging.info("Environment sync running...")
    # Placeholder - sẽ implement khi có config server


@register_command
def d_env_sync():
    """Đồng bộ environment configuration từ remote."""
    _sys_env_sync()
