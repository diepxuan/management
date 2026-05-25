#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_php_composer_install():
    """Cài đặt Composer."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        # Download installer
        subprocess.check_call(
            ["php", "-r", "copy('https://getcomposer.org/installer', 'composer-setup.php');"]
        )
        # Verify signature (skip for now)
        # Install
        subprocess.check_call(
            ["php", "composer-setup.php", "--install-dir=/usr/local/bin", "--filename=composer"]
        )
        # Cleanup
        if os.path.exists("composer-setup.php"):
            os.remove("composer-setup.php")
        logging.info("Composer đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài Composer: {e}")


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
