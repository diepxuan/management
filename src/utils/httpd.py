#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_httpd_install():
    """Cài đặt Apache2 web server."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", "apache2", "libapache2-mod-php"]
        )
        subprocess.check_call(["a2enmod", "rewrite", "ssl", "headers"])
        logging.info("Apache2 đã được cài đặt")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài Apache2: {e}")


@register_command
def d_httpd_config(args=None):
    """
    Cấu hình Apache2 virtual host.
    Usage: ductn httpd:config <domain>
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args:
        logging.error("Usage: ductn httpd:config <domain>")
        return

    domain = args[0] if isinstance(args, list) else args
    vhost_path = f"/etc/apache2/sites-available/{domain}.conf"
    doc_root = f"/var/www/{domain}/public_html"

    os.makedirs(doc_root, exist_ok=True)

    vhost_content = f"""<VirtualHost *:80>
    ServerName {domain}
    ServerAlias www.{domain}
    DocumentRoot {doc_root}

    <Directory {doc_root}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${{APACHE_LOG_DIR}}/{domain}-error.log
    CustomLog ${{APACHE_LOG_DIR}}/{domain}-access.log combined
</VirtualHost>
"""

    with open(vhost_path, "w") as f:
        f.write(vhost_content)

    subprocess.check_call(["a2ensite", f"{domain}.conf"])
    subprocess.check_call(["systemctl", "reload", "apache2"])
    logging.info(f"Đã cấu hình vhost cho {domain}")


@register_command
def d_httpd_restart():
    """Khởi động lại Apache2."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["systemctl", "restart", "apache2"])
        logging.info("Apache2 đã restart")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi restart Apache2: {e}")


@register_command
def d_httpd_config_sites():
    """Liệt kê các virtual host đã cấu hình."""
    try:
        result = subprocess.run(
            ["apache2ctl", "-S"],
            capture_output=True,
            text=True,
            check=True,
        )
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi liệt kê sites: {e.stderr}")
