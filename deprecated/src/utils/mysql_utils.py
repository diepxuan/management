#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


@register_command
def d_mysql_setup():
    """Setup MySQL: cài đặt, secure, tạo root password."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(
            ["apt-get", "install", "-y", "mysql-server"]
        )
        logging.info("MySQL server đã được cài đặt")

        # Secure installation
        subprocess.check_call(["mysql_secure_installation"])
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi cài đặt MySQL: {e}")


@register_command
def d_mysql_ssl_enable():
    """Bật SSL cho MySQL."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    ssl_dir = "/etc/mysql/ssl"
    os.makedirs(ssl_dir, exist_ok=True)

    # Tạo self-signed SSL certs
    try:
        subprocess.check_call([
            "openssl", "req", "-newkey", "rsa:2048", "-days", "365",
            "-nodes", "-x509",
            "-subj", "/CN=mysql-server",
            "-keyout", f"{ssl_dir}/server-key.pem",
            "-out", f"{ssl_dir}/server-cert.pem",
        ])
        os.chmod(f"{ssl_dir}/server-key.pem", 0o600)
        logging.info("Đã tạo SSL certificates cho MySQL")

        # Cấu hình MySQL sử dụng SSL
        cnf_path = "/etc/mysql/mysql.conf.d/99-ssl.cnf"
        with open(cnf_path, "w") as f:
            f.write(f"""[mysqld]
ssl-ca = {ssl_dir}/server-cert.pem
ssl-cert = {ssl_dir}/server-cert.pem
ssl-key = {ssl_dir}/server-key.pem
require_secure_transport = ON
""")

        subprocess.check_call(["systemctl", "restart", "mysql"])
        logging.info("MySQL SSL đã được bật")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi bật MySQL SSL: {e}")
