#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_ssh_cleanup():
    """Dọn dẹp và sắp xếp lại SSH authorized_keys, loại bỏ dòng trùng."""
    auth_keys = os.path.expanduser("~/.ssh/authorized_keys")
    if not os.path.exists(auth_keys):
        logging.info("Không tìm thấy ~/.ssh/authorized_keys")
        return

    try:
        with open(auth_keys, "r") as f:
            lines = f.readlines()
        unique = sorted(set(lines))
        with open(auth_keys, "w") as f:
            f.writelines(unique)
        logging.info(f"Đã dọn dẹp SSH keys: {len(lines)} -> {len(unique)} keys")
    except Exception as e:
        logging.error(f"Lỗi khi dọn dẹp SSH keys: {e}")


def _fix_ssh_permissions():
    ssh_dir = os.path.expanduser("~/.ssh")
    os.makedirs(ssh_dir, exist_ok=True)
    os.chmod(ssh_dir, 0o700)

    for filename in os.listdir(ssh_dir):
        filepath = os.path.join(ssh_dir, filename)
        if os.path.isfile(filepath):
            os.chmod(filepath, 0o600)


@register_command
def d_ssh_install():
    """Cài đặt SSH: tạo public key từ private key, sửa permissions."""
    ssh_dir = os.path.expanduser("~/.ssh")
    id_rsa = os.path.join(ssh_dir, "id_rsa")

    if os.path.exists(id_rsa):
        try:
            result = subprocess.run(
                ["ssh-keygen", "-y", "-f", id_rsa],
                capture_output=True,
                text=True,
                check=True,
            )
            pub_path = os.path.join(ssh_dir, "id_rsa.pub")
            with open(pub_path, "w") as f:
                f.write(result.stdout)
            logging.info("Đã tạo public key từ private key")
        except subprocess.CalledProcessError as e:
            logging.error(f"Lỗi tạo public key: {e.stderr}")
    else:
        logging.warning("Không tìm thấy ~/.ssh/id_rsa, bỏ qua tạo public key")

    _fix_ssh_permissions()


@register_command
def d_ssh_copy(args=None):
    """
    Copy SSH key tới remote server.
    Usage: ductn ssh:copy user@host
    """
    if not args:
        logging.error("Usage: ductn ssh:copy <user@host>")
        return

    remote = args[0] if isinstance(args, list) else args
    local_key = os.path.expanduser("~/.ssh/id_rsa")

    if not os.path.exists(local_key):
        logging.error(f"Không tìm thấy {local_key}")
        return

    try:
        with open(local_key, "r") as f:
            key_content = f.read()

        # Copy key file tới remote
        cmd = (
            f'echo \'{key_content.strip()}\' | ssh {remote} '
            '"cat > ~/.ssh/id_rsa && chmod 600 ~/.ssh/* && '
            'ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub"'
        )
        subprocess.run(cmd, shell=True, check=True)
        logging.info(f"Đã copy SSH key tới {remote}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi copy SSH key tới {remote}: {e}")
