#!/usr/bin/env python3

import hashlib
import logging
import os
import subprocess
import tempfile
import urllib.request

from .registry import register_command
from .system import _is_root

COMPOSER_INSTALLER_URL = "https://getcomposer.org/installer"
COMPOSER_SIGNATURE_URL = "https://composer.github.io/installer.sig"


def _fetch_composer_signature():
    """Tải SHA384 chính thức của composer installer."""
    with urllib.request.urlopen(COMPOSER_SIGNATURE_URL, timeout=30) as resp:
        return resp.read().decode().strip()


def _verify_composer_installer(path, expected):
    """So SHA384 của file với signature; trả True nếu khớp."""
    digest = hashlib.sha384()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            digest.update(chunk)
    return digest.hexdigest() == expected


@register_command
def d_php_composer_install():
    """
    Cài đặt Composer (có verify SHA384 như bash gốc).

    Bash `php.sh` tải installer rồi so SHA384 với composer.github.io/
    installer.sig trước khi chạy. Python trước 5.8.7 bỏ qua bước verify
    (comment "Verify signature (skip for now)") — nay làm đúng.
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    tmpdir = tempfile.mkdtemp(prefix="ductn-composer-")
    installer = os.path.join(tmpdir, "composer-setup.php")

    try:
        logging.info("Tải composer installer…")
        urllib.request.urlretrieve(COMPOSER_INSTALLER_URL, installer)

        logging.info("Kiểm tra chữ ký SHA384…")
        expected = _fetch_composer_signature()
        if not _verify_composer_installer(installer, expected):
            logging.error(
                "Installer composer KHÔNG hợp lệ (SHA384 không khớp). Đã dừng."
            )
            return

        logging.info("Chữ ký hợp lệ, đang cài…")
        subprocess.check_call(
            [
                "php",
                installer,
                "--install-dir=/usr/local/bin",
                "--filename=composer",
            ]
        )
        logging.info("Composer đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài Composer: {e}")
    except OSError as e:
        logging.error(f"Lỗi tải Composer: {e}")
    finally:
        try:
            os.remove(installer)
        except OSError:
            pass
        try:
            os.rmdir(tmpdir)
        except OSError:
            pass


@register_command
def d_php_apt_install():
    """Cài đặt PHP và các extension phổ biến qua APT."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    packages = [
        "php", "php-cli", "php-fpm", "php-mysql", "php-pgsql",
        "php-xml", "php-mbstring", "php-curl", "php-zip", "php-gd",
        "php-intl", "php-soap", "php-redis", "php-memcached",
    ]

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y"] + packages
        )
        logging.info("PHP và các extension đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài PHP: {e}")


@register_command
def d_php_install():
    """Cài đặt PHP + Composer."""
    d_php_apt_install()
    d_php_composer_install()


@register_command
def d_php_phpcsfixer_install():
    """Cài đặt PHP CS Fixer."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["wget", "https://github.com/FriendsOfPHP/PHP-CS-Fixer/releases/latest/download/php-cs-fixer.phar", "-O", "/usr/local/bin/php-cs-fixer"]
        )
        os.chmod("/usr/local/bin/php-cs-fixer", 0o755)
        logging.info("PHP CS Fixer đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài PHP CS Fixer: {e}")
