#!/usr/bin/env python3

"""SSH cleanup: deduplicate authorized_keys, fix permissions, xóa host key cũ.

Usage:
    ductn ssh:cleanup
        Deduplicate authorized_keys + fix permissions.
    ductn ssh:cleanup <ip_or_hostname>
        Xóa host key cũ khỏi known_hosts (LXC/VM thay đổi, cùng IP).
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


def _remove_known_hosts_entry(target):
    """Xóa tất cả dòng matching target khỏi ~/.ssh/known_hosts.

    Tương đương `ssh-keygen -R <target>` nhưng không cần gọi subprocess.
    Giữ nguyên các host key khác, xóa cả hashed và unhashed entries.
    """
    known_hosts = os.path.expanduser("~/.ssh/known_hosts")
    if not os.path.isfile(known_hosts):
        logging.info(f"~/.ssh/known_hosts không tồn tại, bỏ qua xóa key cho {target}")
        return

    try:
        with open(known_hosts, "r") as f:
            lines = f.readlines()
    except OSError as e:
        logging.error(f"Không thể đọc {known_hosts}: {e}")
        return

    unique_lines = []
    removed = 0
    for line in lines:
        stripped = line.strip()
        # known_hosts format: host1,host2,... key_type key_data [comment]
        # Hoặc hashed: |1|base64... key_type key_data
        host_part = stripped.split(" ")[0] if stripped else ""

        # Check nếu target xuất hiện trong host list (unhashed)
        if target in host_part:
            removed += 1
            continue

        unique_lines.append(line)

    if removed > 0:
        try:
            with open(known_hosts, "w") as f:
                f.writelines(unique_lines)
            logging.info(
                f"SSH cleanup: đã xóa {removed} host key cũ cho '{target}' "
                f"từ known_hosts"
            )
        except OSError as e:
            logging.error(f"Không thể ghi {known_hosts}: {e}")
    else:
        logging.info(
            f"SSH cleanup: không tìm thấy host key cho '{target}' trong known_hosts"
        )


def _deduplicate_authorized_keys():
    """Loại bỏ dòng trùng trong authorized_keys, giữ thứ tự."""
    auth_keys = os.path.expanduser("~/.ssh/authorized_keys")

    if not os.path.isfile(auth_keys):
        logging.info("~/.ssh/authorized_keys không tồn tại, bỏ qua dedup")
        return

    try:
        with open(auth_keys, "r") as f:
            lines = f.readlines()
    except OSError as e:
        logging.error(f"Không thể đọc {auth_keys}: {e}")
        return

    seen = set()
    unique_lines = []
    removed = 0
    for line in lines:
        stripped = line.strip()
        if stripped == "" or stripped.startswith("#"):
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
                f"SSH authorized_keys: {len(lines)} -> {len(unique_lines)} lines "
                f"(loại {removed} dòng trùng)"
            )
        except OSError as e:
            logging.error(f"Không thể ghi {auth_keys}: {e}")
    else:
        logging.info("SSH authorized_keys: không có dòng trùng nào")


@register_command
def d_ssh_cleanup(args=None):
    """Dọn dẹp SSH: dedup authorized_keys, fix permissions, hoặc xóa host key cũ.

    - Không có arg: dedup authorized_keys + fix permissions
    - Có arg (IP/hostname): xóa host key cũ khỏi known_hosts cho target đó
    """
    if args:
        target = args[0] if isinstance(args, list) else args
        logging.info(f"SSH cleanup: xóa host key cho '{target}'")
        _remove_known_hosts_entry(target)
        _fix_ssh_permissions()
    else:
        _deduplicate_authorized_keys()
        _fix_ssh_permissions()
        logging.info("SSH permissions: ~/.ssh=0o700, ~/.ssh/*=0o600")
