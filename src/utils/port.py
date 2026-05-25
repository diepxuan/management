#!/usr/bin/env python3

import subprocess
import logging

from .registry import register_command


@register_command
def d_port_open():
    """Hiển thị các port đang ở trạng thái LISTEN."""
    try:
        result = subprocess.run(
            ["lsof", "-nP"],
            capture_output=True,
            text=True,
            check=True,
        )
        for line in result.stdout.splitlines():
            if "LISTEN" in line:
                print(line)
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi khi chạy lsof: {e.stderr}")
    except FileNotFoundError:
        logging.error("Không tìm thấy lsof. Cài đặt: apt install lsof")
