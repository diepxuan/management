#!/usr/bin/env python3

import logging
import secrets
import string
import subprocess

from .registry import register_command


def _logger(message, level="info"):
    if level == "error":
        logging.error(message)
    elif level == "warning":
        logging.warning(message)
    else:
        logging.info(message)


@register_command
def d_echo(args=None):
    """Echo message (debug command)."""
    if args:
        print(" ".join(args) if isinstance(args, list) else args)


# --- Salvage từ src/var/lib/functions.sh (xoá ở 5.8.7) --------------------
# `--hash_MD5` sinh chuỗi 20 ký tự từ $RANDOM + md5sum, dùng làm hậu tố
# ngẫu nhiên cho tên file/thư mục tạm. Chưa từng có bản Python.
# Bản này dùng `secrets` thay `$RANDOM` — không đoán được, cùng độ dài.

_ALPHABET = string.ascii_lowercase + string.digits


def _random_suffix(length=20):
    """Sinh chuỗi ngẫu nhiên ``length`` ký tự (chữ thường + số)."""
    return "".join(secrets.choice(_ALPHABET) for _ in range(length))


@register_command
def d_hash_md5():
    """
    Sinh chuỗi ngẫu nhiên 20 ký tự, dùng làm hậu tố tên file/temp.
    Usage: ductn hash:md5

    Tương đương bash `echo $RANDOM | md5sum | head -c 20` nhưng dùng
    `secrets` thay `$RANDOM`.
    """
    print(_random_suffix())


@register_command
def d_ssh(args=None):
    """
    Chạy lệnh trên host từ xa qua SSH, không cấp TTY.
    Usage: ductn ssh <host> <command...>

    Tương đương bash `ssh -T $1 "$2" 2>/dev/null`. Bash nuốt stderr;
    bản Python giữ lại dưới dạng warning để còn debug.
    """
    if not args or len(args) < 2:
        logging.error("Usage: ductn ssh <host> <command...>")
        return

    host = args[0]
    command = " ".join(args[1:])

    try:
        result = subprocess.run(
            ["ssh", "-T", host, command],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.stdout:
            print(result.stdout, end="")
        if result.stderr:
            logging.warning("ssh stderr: %s", result.stderr.strip())
        return result.returncode
    except FileNotFoundError:
        logging.error("Không tìm thấy lệnh ssh")
