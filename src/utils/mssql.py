#!/usr/bin/env python3
"""Microsoft SQL Server / SQLSRV driver setup (migrated from src/var/lib/mssql.sh).

The bash script was written for Ubuntu 16.04–22.04 and used ``apt-key``, which
was deprecated in Debian 12 and removed in Ubuntu 24.04 (noble, the current
package target). The migration therefore reimplements the repository setup with
a dearmored keyring under ``/etc/apt/keyrings`` — the commands keep their old
names, but the plumbing is current.

Dropped from the bash version:

* ``sqlsrv:ad:spn`` — it mixed PowerShell ``New-ADUser``/``Setspn`` (run on the
  domain controller) with ``ktpass``/``ktutil`` incantations and an embedded
  domain password. That is a runbook, not a command; shipping it as a package
  command would put a credential in argv. Kept as documentation in
  ``docs/MSSQL-AD-SPN.md``.
* ``sqlsrv:cron`` — it just called ``__sqlsrv:install`` and was never
  registered as a command.
* Every commented-out block pinning PHP 5.6/7.x ini paths.
"""

import glob
import logging
import os
import subprocess

from .registry import register_command
from .system import _is_root

MICROSOFT_KEY_URL = "https://packages.microsoft.com/keys/microsoft.asc"
KEYRING_PATH = "/etc/apt/keyrings/microsoft-prod.asc"
MSSQL_REPO = "https://packages.microsoft.com/config/ubuntu/{release}/mssql-server-2019.list"
PROD_REPO = "https://packages.microsoft.com/config/ubuntu/{release}/prod.list"

# Mã Ubuntu còn được Microsoft hỗ trợ cho SQL Server 2019/2022.
SUPPORTED_UBUNTU = ("20.04", "22.04", "24.04")


def _ubuntu_release():
    """Đọc VERSION_ID từ /etc/os-release."""
    try:
        with open("/etc/os-release", "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("VERSION_ID="):
                    return line.split("=", 1)[1].strip().strip('"')
    except OSError:
        pass
    return ""


def _check_platform():
    """Xác nhận đang chạy Ubuntu được hỗ trợ."""
    from .system_os import _os_distro as distro_id

    if distro_id() != "ubuntu":
        logging.error(
            "Chỉ hỗ trợ Ubuntu (phát hiện: %s). Microsoft không phát hành "
            "repo cho distro này.",
            distro_id() or "unknown",
        )
        return None

    release = _ubuntu_release()
    if release not in SUPPORTED_UBUNTU:
        logging.error(
            "Ubuntu %s không được hỗ trợ. Hỗ trợ: %s",
            release or "?",
            ", ".join(SUPPORTED_UBUNTU),
        )
        return None

    return release


def _install_repo_key():
    """
    Tải Microsoft signing key vào /etc/apt/keyrings (thay cho apt-key).

    ``apt-key`` đã bị bỏ; cách hiện hành là keyring riêng + ``signed-by``
    trong sources.list.
    """
    import urllib.request

    os.makedirs(os.path.dirname(KEYRING_PATH), exist_ok=True)
    try:
        with urllib.request.urlopen(MICROSOFT_KEY_URL, timeout=30) as resp:
            key = resp.read()
    except OSError as e:
        logging.error("Không tải được Microsoft key: %s", e)
        return False

    try:
        with open(KEYRING_PATH, "wb") as f:
            f.write(key)
        os.chmod(KEYRING_PATH, 0o644)
    except OSError as e:
        logging.error("Không ghi được %s: %s", KEYRING_PATH, e)
        return False

    logging.info("Đã cài Microsoft key tại %s", KEYRING_PATH)
    return True


def _add_repo(url, list_path):
    """Ghi một dòng deb vào sources.list.d với ``signed-by``."""
    line = f"deb [arch=amd64,arm64,armhf signed-by={KEYRING_PATH}] {url} stable main\n"
    try:
        with open(list_path, "w", encoding="utf-8") as f:
            f.write(line)
        os.chmod(list_path, 0o644)
    except OSError as e:
        logging.error("Không ghi được %s: %s", list_path, e)
        return False

    logging.info("Đã thêm repo: %s", url)
    return True


@register_command
def d_sqlsrv_apt():
    """
    Thêm Microsoft APT repo cho SQL Server và driver (Ubuntu).
    Usage: ductn sqlsrv:apt

    Dùng keyring + signed-by thay cho `apt-key` (đã bị bỏ ở Debian 12 /
    Ubuntu 24.04).
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    release = _check_platform()
    if not release:
        return

    if not _install_repo_key():
        return

    if not _add_repo(
        MSSQL_REPO.format(release=release),
        "/etc/apt/sources.list.d/mssql-server-2019.list",
    ):
        return

    subprocess.run(["apt-get", "update"], check=False)


# Alias giữ tên bash cũ.
@register_command
def d_sqlsrv_apt_install():
    """Alias của `sqlsrv:apt` (tên bash cũ)."""
    return d_sqlsrv_apt()


@register_command
def d_sqlsrv_install():
    """
    Cài SQL Server 2019 và chạy cấu hình ban đầu (Ubuntu).
    Usage: ductn sqlsrv:install
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not _check_platform():
        return

    d_sqlsrv_apt()

    try:
        subprocess.check_call(["apt-get", "install", "-y", "mssql-server"])
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi cài mssql-server: %s", e)
        return

    logging.info("Đang chạy cấu hình SQL Server (mssql-conf setup)…")
    try:
        subprocess.check_call(["/opt/mssql/bin/mssql-conf", "setup"])
    except (FileNotFoundError, subprocess.CalledProcessError) as e:
        logging.error("Lỗi cấu hình SQL Server: %s", e)


@register_command
def d_mssql_install():
    """Alias của `sqlsrv:install` (tên bash cũ)."""
    return d_sqlsrv_install()


@register_command
def d_sqlsrv_php_install():
    """
    Cài ODBC driver + PHP extension sqlsrv/pdo_sqlsrv (Ubuntu).
    Usage: ductn sqlsrv:php:install
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    release = _check_platform()
    if not release:
        return

    d_sqlsrv_apt()

    # Driver ODBC cho SQL Server cần repo prod (không phải repo mssql-server).
    if not _add_repo(
        PROD_REPO.format(release=release),
        "/etc/apt/sources.list.d/mssql-release.list",
    ):
        return

    subprocess.run(["apt-get", "update"], check=False)

    try:
        subprocess.check_call(["apt-get", "install", "-y", "php-dev", "php-xml"])
        env = dict(os.environ, ACCEPT_EULA="Y")
        subprocess.check_call(
            [
                "apt-get", "install", "-y",
                "msodbcsql17", "mssql-tools", "locales", "unixodbc-dev",
            ],
            env=env,
        )
        subprocess.call(["locale-gen", "en_US.utf8"])
        subprocess.call(["update-locale"])
        subprocess.check_call(["pecl", "install", "sqlsrv", "pdo_sqlsrv"])
    except FileNotFoundError as e:
        logging.error("Thiếu lệnh: %s", e)
        return
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi cài driver: %s", e)
        return

    logging.info("Đã cài sqlsrv/pdo_sqlsrv. Bật extension: ductn sqlsrv:php:enable")


def _php_scan_dir():
    """
    Thư mục gốc của PHP đang dùng (vd ``/etc/php/8.3``).

    Bash gọi `php --ini` rồi sed để lấy đường dẫn — giữ cách đó vì nó đúng
    với mọi phiên bản PHP (không hardcode /etc/php/8.x).

    Chỉ đọc dòng "Loaded Configuration File": ``/etc/php/8.3/cli/php.ini``.
    Dòng "Configuration File (php.ini) Path" trỏ tới thư mục ``cli`` và sẽ
    cho kết quả sai nếu dùng nhầm.
    """
    try:
        result = subprocess.run(
            ["php", "--ini"], capture_output=True, text=True, check=True
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        return None

    for line in result.stdout.splitlines():
        if "Loaded Configuration File" in line:
            path = line.split(":", 1)[1].strip()
            if not path:
                continue
            # /etc/php/8.3/cli/php.ini -> /etc/php/8.3
            return os.path.dirname(os.path.dirname(path))
    return None


@register_command
def d_sqlsrv_php_enable():
    """
    Bật PHP extension sqlsrv + pdo_sqlsrv (Ubuntu).
    Usage: ductn sqlsrv:php:enable

    Sinh file mods-available rồi gọi phpenmod, đúng như bash gốc nhưng
    không hardcode phiên bản PHP.
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    mods_dir = _php_scan_dir()
    if not mods_dir:
        logging.error("Không xác định được thư mục PHP (php --ini thất bại)")
        return

    available = os.path.join(mods_dir, "mods-available")
    try:
        os.makedirs(available, exist_ok=True)
        with open(os.path.join(available, "sqlsrv.ini"), "w", encoding="utf-8") as f:
            f.write("priority=20\nextension=sqlsrv.so\n")
        with open(os.path.join(available, "pdo_sqlsrv.ini"), "w", encoding="utf-8") as f:
            f.write("priority=30\nextension=pdo_sqlsrv.so\n")
    except OSError as e:
        logging.error("Không ghi được ini: %s", e)
        return

    try:
        subprocess.check_call(["phpenmod", "sqlsrv", "pdo_sqlsrv"])
        logging.info("Đã bật sqlsrv + pdo_sqlsrv")
    except (FileNotFoundError, subprocess.CalledProcessError) as e:
        logging.error("phpenmod thất bại: %s", e)


@register_command
def d_sqlsrv_php_disable():
    """
    Tắt PHP extension sqlsrv + pdo_sqlsrv (Ubuntu).
    Usage: ductn sqlsrv:php:disable
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    try:
        subprocess.check_call(["phpdismod", "sqlsrv", "pdo_sqlsrv"])
        logging.info("Đã tắt sqlsrv + pdo_sqlsrv")
    except (FileNotFoundError, subprocess.CalledProcessError) as e:
        logging.error("phpdismod thất bại: %s", e)


@register_command
def d_mssql_php_install():
    """Alias của `sqlsrv:php:install` (tên bash cũ)."""
    return d_sqlsrv_php_install()


@register_command
def d_mssql_php_enable():
    """Alias của `sqlsrv:php:enable` (tên bash cũ)."""
    return d_sqlsrv_php_enable()


@register_command
def d_mssql_php_disable():
    """Alias của `sqlsrv:php:disable` (tên bash cũ)."""
    return d_sqlsrv_php_disable()
