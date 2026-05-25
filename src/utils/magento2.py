#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


def _run_magento(cmd, *args):
    try:
        full_cmd = ["php", "bin/magento", cmd] + list(args)
        subprocess.run(full_cmd, check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Magento error: {e}")


def _run_n98_magerun2(cmd, *args):
    try:
        full_cmd = ["n98-magerun2", cmd] + list(args)
        subprocess.run(full_cmd, check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"Magerun2 error: {e}")


@register_command
def d_php_m2(args=None):
    """
    Magento 2 helper commands.
    Usage: ductn php:m2 <command>
    """
    if not args:
        print("Magento 2 helper commands:")
        print("  m2:ch [path]          - Fix permissions")
        print("  m2:cache              - Cache management")
        print("  m2:index              - Reindex")
        print("  m2:static             - Deploy static content")
        print("  m2:up                 - Run upgrade")
        print("  m2:config             - Show config")
        print("  m2:developer          - Enable developer mode")
        print("  m2:rmgen              - Remove generated files")
        return

    cmd = args[0] if isinstance(args, list) else args

    if cmd == "ch":
        path = args[1] if len(args) > 1 else "."
        _fix_magento_permissions(path)
    elif cmd == "cache":
        for action in ["clean", "flush"]:
            _run_magento("cache", action)
    elif cmd == "index":
        _run_magento("indexer", "reindex")
    elif cmd == "static":
        _run_magento("setup:static-content:deploy", "-f")
    elif cmd == "up":
        _run_magento("setup:upgrade")
    elif cmd == "config":
        _run_magento("config:show")
    elif cmd == "developer":
        _run_magento("deploy:mode:set", "developer")
    elif cmd == "rmgen":
        for d in ["generated", "var/cache", "var/page_cache", "var/view_preprocessed"]:
            if os.path.exists(d):
                subprocess.run(["rm", "-rf", d])
        logging.info("Đã xóa generated files")
    elif cmd == "logenable":
        _run_magento("dev:log", "enable")
    elif cmd == "logdisable":
        _run_magento("dev:log", "disable")
    elif cmd == "tempdebugenable":
        _run_magento("dev:template-hints", "enable")
    elif cmd == "tempdebugdisable":
        _run_magento("dev:template-hints", "disable")
    else:
        logging.error(f"Unknown Magento 2 command: {cmd}")


def _fix_magento_permissions(path="."):
    """Fix Magento file permissions."""
    try:
        subprocess.run(["find", path, "-type", "d", "-exec", "chmod", "755", "{}", ";"])
        subprocess.run(["find", path, "-type", "f", "-exec", "chmod", "644", "{}", ";"])
        subprocess.run(["chmod", "-R", "777", f"{path}/var", f"{path}/pub/media", f"{path}/pub/static"])
        logging.info("Đã fix Magento permissions")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi fix permissions: {e}")


@register_command
def d_m2_completion():
    """Magento 2 bash completion."""
    print("Magento 2 completion not implemented yet")
