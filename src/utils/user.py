#!/usr/bin/env python3

import os
import subprocess
import logging
import pwd

from .registry import register_command
from .system import _is_root


@register_command
def d_user_new(args=None):
    """
    Tạo user mới.
    Usage: ductn user:new <username>
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args:
        logging.error("Usage: ductn user:new <username>")
        return

    username = args[0] if isinstance(args, list) else args
    try:
        subprocess.check_call(["useradd", "-m", "-s", "/bin/bash", username])
        logging.info(f"Đã tạo user {username}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi tạo user {username}: {e}")


def _user_config_chmod(username=None):
    if not username:
        username = os.getenv("SUDO_USER", os.getenv("USER"))

    home = os.path.expanduser(f"~{username}") if username else os.path.expanduser("~")
    if not os.path.exists(home):
        logging.error(f"Home directory không tồn tại: {home}")
        return

    os.chmod(home, 0o750)
    for item in os.listdir(home):
        path = os.path.join(home, item)
        if os.path.isdir(path):
            os.chmod(path, 0o750)
        elif os.path.isfile(path):
            os.chmod(path, 0o640)


@register_command
def d_user_config(args=None):
    """
    Cấu hình user (bash, permissions, admin).
    Usage: ductn user:config <username> [bash|chmod|admin]
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args:
        logging.error("Usage: ductn user:config <username> [bash|chmod|admin]")
        return

    username = args[0] if len(args) > 0 else None
    action = args[1] if len(args) > 1 else "chmod"

    if not username:
        logging.error("Cần truyền username")
        return

    if action == "bash":
        d_user_config_bash(username)
    elif action == "chmod":
        _user_config_chmod(username)
        logging.info(f"Đã sửa permissions cho {username}")
    elif action == "admin":
        d_user_config_admin(username)
    else:
        logging.error(f"Action không hợp lệ: {action}")


def d_user_config_bash(username):
    """Setup bash config cho user."""
    home = os.path.expanduser(f"~{username}")
    bashrc = os.path.join(home, ".bashrc")
    if not os.path.exists(bashrc):
        with open(bashrc, "w") as f:
            f.write("# ~/.bashrc\n")
        subprocess.check_call(["chown", f"{username}:{username}", bashrc])
    logging.info(f"Đã setup bash cho {username}")


def d_user_config_admin(username):
    """Thêm user vào nhóm sudo."""
    try:
        subprocess.check_call(["usermod", "-aG", "sudo", username])
        logging.info(f"Đã thêm {username} vào nhóm sudo")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi thêm {username} vào sudo: {e}")


@register_command
def d_user_is_sudoer(args=None):
    """Kiểm tra user có quyền sudo không."""
    if not args:
        username = os.getenv("SUDO_USER", os.getenv("USER", "root"))
    else:
        username = args[0] if isinstance(args, list) else args

    try:
        user_info = pwd.getpwnam(username)
        groups = subprocess.run(
            ["groups", username], capture_output=True, text=True
        ).stdout
        if "sudo" in groups or "wheel" in groups:
            print(f"{username} là sudoer")
        else:
            print(f"{username} không phải sudoer")
    except KeyError:
        print(f"User {username} không tồn tại")
