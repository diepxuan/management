#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command


@register_command
def d_php_lar(args=None):
    """
    Laravel helper commands.
    Usage: ductn php:lar [command]
    """
    if not args:
        # Liệt kê các Laravel commands phổ biến
        print("Laravel helper commands:")
        print("  lar:artisan <cmd>    - Chạy artisan command")
        print("  lar:composer <cmd>   - Chạy composer command")
        print("  lar:cache:clear      - Xóa cache")
        print("  lar:config:cache     - Cache config")
        print("  lar:route:cache      - Cache routes")
        print("  lar:view:cache       - Cache views")
        return

    cmd = args[0] if isinstance(args, list) else args

    if cmd.startswith("artisan"):
        artisan_cmd = " ".join(args[1:]) if len(args) > 1 else ""
        try:
            subprocess.run(f"php artisan {artisan_cmd}", shell=True, check=True)
        except subprocess.CalledProcessError as e:
            logging.error(f"Lỗi artisan: {e}")
    elif cmd.startswith("composer"):
        composer_cmd = " ".join(args[1:]) if len(args) > 1 else ""
        try:
            subprocess.run(f"composer {composer_cmd}", shell=True, check=True)
        except subprocess.CalledProcessError as e:
            logging.error(f"Lỗi composer: {e}")
    elif cmd == "cache:clear":
        for c in ["cache", "route", "config", "view"]:
            try:
                subprocess.check_call(["php", "artisan", f"{c}:clear"])
            except subprocess.CalledProcessError:
                pass
        logging.info("Đã xóa Laravel cache")
    elif cmd == "config:cache":
        try:
            subprocess.check_call(["php", "artisan", "config:cache"])
        except subprocess.CalledProcessError:
            pass
    elif cmd == "route:cache":
        try:
            subprocess.check_call(["php", "artisan", "route:cache"])
        except subprocess.CalledProcessError:
            pass
    else:
        logging.error(f"Unknown Laravel command: {cmd}")
