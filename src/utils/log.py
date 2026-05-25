#!/usr/bin/env python3

import os
import glob
import subprocess
import logging
import shutil

from .registry import register_command
from .system import _is_root


@register_command
def d_log():
    """Hiển thị system log (alias của log:watch)."""
    d_log_watch()


def _watch_all_logs():
    log_files = glob.glob("/var/log/*log")
    mssql_log = "/var/opt/mssql/log/errorlog"
    if os.path.exists(mssql_log):
        log_files.append(mssql_log)

    if not log_files:
        logging.warning("Không tìm thấy log files")
        return

    try:
        cmd = ["tail", "-f"] + log_files
        subprocess.call(cmd)
    except KeyboardInterrupt:
        pass


@register_command
def d_log_watch(args=None):
    """
    Theo dõi log theo thời gian thực.
    Usage: ductn log:watch [service_name]
    """
    if args:
        service = args[0] if isinstance(args, list) else args
        service = service.replace(".service", "")
        try:
            subprocess.call(["journalctl", "-u", f"{service}.service", "-f"])
        except KeyboardInterrupt:
            pass
    else:
        _watch_all_logs()


@register_command
def d_log_cleanup():
    """Dọn dẹp log files: truncate, xóa rotated logs, xóa trash."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    # Truncate tất cả log files
    log_files = glob.glob("/var/log/**/*", recursive=True)
    log_files += glob.glob("/var/log/*", recursive=False)
    for log_file in set(log_files):
        if os.path.isfile(log_file):
            try:
                with open(log_file, "w") as f:
                    pass  # truncate
            except (PermissionError, OSError):
                pass

    # Xóa rotated logs (.gz, .1, .2...)
    for pattern in ["/var/log/**/*.gz", "/var/log/**/*.?"]:
        for f in glob.glob(pattern, recursive=True):
            try:
                os.remove(f)
            except (PermissionError, OSError):
                pass

    # Xóa trash
    for trash_path in ["/home/*/.local/share/Trash/*", "/root/.local/share/Trash/*"]:
        try:
            subprocess.run(f"rm -rf {trash_path}", shell=True)
        except Exception:
            pass

    logging.info("Đã dọn dẹp logs")


LOGROTATE_DUCTN = "/etc/logrotate.d/ductn"


def _log_config_store():
    try:
        import pwd
        pwd.getpwnam("store")
        return """
/home/store/public_html/var/log/*.log {
    su store www-data
    size 1M
    copytruncate
    rotate 1
}
"""
    except KeyError:
        return ""


def _log_config_mssql():
    try:
        import pwd
        pwd.getpwnam("mssql")
        return """
/var/opt/mssql/log/errorlog /var/opt/mssql/log/*.log {
    su mssql mssql
    size 10M
    copytruncate
    missingok
    rotate 1
}
"""
    except KeyError:
        return ""


@register_command
def d_log_config():
    """Cấu hình logrotate cho ductn."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    # Truncate config hiện tại
    with open(LOGROTATE_DUCTN, "w") as f:
        pass

    # Thêm config cho store và mssql
    content = _log_config_store()
    if content:
        with open(LOGROTATE_DUCTN, "a") as f:
            f.write(content)

    content = _log_config_mssql()
    if content:
        with open(LOGROTATE_DUCTN, "a") as f:
            f.write(content)

    # Chạy logrotate
    try:
        subprocess.check_call(["logrotate", "-f", LOGROTATE_DUCTN])
        logging.info("Logrotate đã chạy thành công")
    except subprocess.CalledProcessError as e:
        logging.error(f"Logrotate thất bại: {e}")
