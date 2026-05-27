#!/usr/bin/env python3

"""SSH cleanup: deduplicate authorized_keys và fix permissions.

Usage:
    ductn ssh:cleanup
"""

import os
import stat
import logging

from .registry import register_command


def _fix_ssh_permissions():
    """Đặt permission chuẩn cho ~/.ssh và các file bên trong.

    ~/.ssh        → 0o700 (rwx------)
    ~/.ssh/*      → 0o600 (rw-------)
    """
    ssh_dir = os.path.expanduser("~/.ssh")
    if not os.path.isdir(ssh_dir):
        logging.info("~/.ssh không tồn tại, tạo mới với permission 0o700")
        os.makedirs(ssh_dir, mode=0o700, exist_ok=True)
        return

    os.chmod(ssh_dir, 0o700)
    for filename in os.listdir(ssh_dir):
        filepath = os.path.join(ssh_dir, filename)
        if os.path.isfile(filepath):
            os.chmod(filepath, 0o600)


@register_command
def d_ssh_cleanup():
    """Dọn dẹp SSH: loại bỏ dòng trùng trong authorized_keys, fix permissions.

    - Đọc ~/.ssh/authorized_keys, loại bỏ các dòng giống hệt nhau.
    - Giữ nguyên thứ tự dòng đầu tiên xuất hiện.
    - Set chmod 700 ~/.ssh, chmod 600 ~/.ssh/*.
    """
    auth_keys = os.path.expanduser("~/.ssh/authorized_keys")

    if os.path.isfile(auth_keys):
        try:
            with open(auth_keys, "r") as f:
                lines = f.readlines()
        except OSError as e:
            logging.error(f"Không thể đọc {auth_keys}: {e}")
            _fix_ssh_permissions()
            return

        # Deduplicate giữ thứ tự (preserve first occurrence)
        seen = set()
        unique_lines = []
        removed = 0
        for line in lines:
            stripped = line.strip()
            if stripped == "" or stripped.startswith("#"):
                # Giữ nguyên blank line và comment
                unique_lines.append(line)
                continue
            if stripped in seen:
                removed += 1
                continue
            seen.add(stripped)
            unique_lines.append(line)

        if removed > 0:
            try:
                with open(auth_keys, "w") as f:
                    f.writelines(unique_lines)
                logging.info(
                    f"SSH cleanup: {len(lines)} -> {len(unique_lines)} lines "
                    f"(loại {removed} dòng trùng)"
                )
            except OSError as e:
                logging.error(f"Không thể ghi {auth_keys}: {e}")
        else:
            logging.info("SSH authorized_keys: không có dòng trùng nào")
    else:
        logging.info("~/.ssh/authorized_keys không tồn tại, bỏ qua dedup")

    _fix_ssh_permissions()
    logging.info("SSH permissions: ~/.ssh=0o700, ~/.ssh/*=0o600")
