#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command


@register_command
def d_gpg(args=None):
    """GPG main command."""
    if not args:
        print("GPG commands:")
        print("  gpg:export <key_id> <output_file>")
        print("  gpg:import <key_file>")
        return

    cmd = args[0] if isinstance(args, list) else args
    if cmd == "export":
        key_id = args[1] if len(args) > 1 else None
        output = args[2] if len(args) > 2 else None
        if key_id and output:
            d_gpg_export(key_id, output)
    elif cmd == "import":
        key_file = args[1] if len(args) > 1 else None
        if key_file:
            d_gpg_import(key_file)


def d_gpg_export(key_id, output_file):
    """Export GPG key."""
    try:
        with open(output_file, "wb") as f:
            subprocess.check_call(
                ["gpg", "--export", "--armor", key_id], stdout=f
            )
        logging.info(f"Đã export GPG key {key_id} → {output_file}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi export GPG key: {e}")


@register_command("gpg:export")
def d_gpg_export_cmd(args=None):
    """Export GPG public key."""
    if not args:
        logging.error("Usage: ductn gpg:export <key_id> <output_file>")
        return
    d_gpg_export(args[0], args[1] if len(args) > 1 else f"{args[0]}.asc")


def d_gpg_import(key_file):
    """Import GPG key."""
    if not os.path.exists(key_file):
        logging.error(f"Key file không tồn tại: {key_file}")
        return

    try:
        subprocess.check_call(["gpg", "--import", key_file])
        logging.info(f"Đã import GPG key từ {key_file}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi import GPG key: {e}")


@register_command("gpg:import")
def d_gpg_import_cmd(args=None):
    """Import GPG key."""
    if not args:
        logging.error("Usage: ductn gpg:import <key_file>")
        return
    d_gpg_import(args[0])
