#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root

SWAPFILE = "/swapfile"


@register_command
def d_swap_remove():
    """Gỡ swapfile."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["swapoff", "-v", SWAPFILE])
    except subprocess.CalledProcessError:
        pass  # Có thể đã off rồi

    if os.path.exists(SWAPFILE):
        os.remove(SWAPFILE)
        logging.info(f"Đã xóa {SWAPFILE}")


@register_command
def d_swap_install():
    """Tạo swapfile 2GB."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    # Gỡ swap cũ nếu có
    d_swap_remove()

    # Tạo swapfile mới
    try:
        subprocess.check_call(
            ["fallocate", "-l", "2G", SWAPFILE]
        )
    except subprocess.CalledProcessError:
        # Fallback nếu fallocate không hỗ trợ
        subprocess.check_call(
            ["dd", "if=/dev/zero", f"of={SWAPFILE}", "bs=1M", "count=2048"]
        )

    os.chmod(SWAPFILE, 0o600)
    subprocess.check_call(["mkswap", SWAPFILE])
    subprocess.check_call(["swapon", SWAPFILE])
    logging.info(f"Đã tạo swapfile {SWAPFILE} (2GB)")
