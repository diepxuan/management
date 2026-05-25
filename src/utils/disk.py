#!/usr/bin/env python3

import os
import subprocess
import logging

from .registry import register_command
from .system import _is_root


def _check_disk_health(sectorsize="4k"):
    """Kiểm tra disk health theo sector size."""
    try:
        result = subprocess.run(
            ["smartctl", "-a", "/dev/sda"],
            capture_output=True,
            text=True,
            check=True,
        )
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(f"smartctl thất bại: {e.stderr}")
    except FileNotFoundError:
        logging.error("Không tìm thấy smartctl. Cài đặt: apt install smartmontools")


@register_command
def d_disk_check(args=None):
    """
    Kiểm tra disk health.
    Usage: ductn disk:check [--sector-size 4k|8k|512]
    Nếu không truyền --sector-size, chạy cả 3 mode (4k, 8k, 512).
    """
    sector_size = None
    if args:
        arg_list = args if isinstance(args, list) else args.split()
        i = 0
        while i < len(arg_list):
            if arg_list[i] == "--sector-size" and i + 1 < len(arg_list):
                sector_size = arg_list[i + 1]
                i += 2
            else:
                i += 1

    if sector_size:
        _check_disk_health(sector_size)
    else:
        for size in ("4k", "8k", "512"):
            logging.info(f"Checking disk health with sector size: {size}")
            _check_disk_health(size)


def _zfs_disk_list():
    """Liệt kê ZFS disks."""
    try:
        result = subprocess.run(
            ["zpool", "status"], capture_output=True, text=True, check=True
        )
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(f"zpool status thất bại: {e.stderr}")
    except FileNotFoundError:
        logging.error("ZFS không khả dụng")


@register_command
def d_zfs_disk_list():
    """Liệt kê ZFS disks."""
    _zfs_disk_list()


@register_command
def d_zfs_disk_offline(args=None):
    """Take ZFS disk offline."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args:
        logging.error("Usage: ductn zfs:disk:offline <pool> <disk>")
        return

    pool, disk = args[0], args[1]
    try:
        subprocess.check_call(["zpool", "offline", pool, disk])
        logging.info(f"Đã offline {disk} từ pool {pool}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi offline disk: {e}")


@register_command
def d_zfs_disk_replace(args=None):
    """Replace ZFS disk."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 2:
        logging.error("Usage: ductn zfs:disk:replace <pool> <old_disk> [new_disk]")
        return

    pool, old_disk = args[0], args[1]
    new_disk = args[2] if len(args) > 2 else None

    cmd = ["zpool", "replace", pool, old_disk]
    if new_disk:
        cmd.append(new_disk)

    try:
        subprocess.check_call(cmd)
        logging.info(f"Đã replace disk trong pool {pool}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi replace disk: {e}")


@register_command
def d_zfs_disk_replace_boot_disk(args=None):
    """Replace boot disk trong ZFS pool."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 2:
        logging.error("Usage: ductn zfs:disk:replace_boot_disk <pool> <new_disk>")
        return

    pool, new_disk = args[0], args[1]
    try:
        subprocess.check_call(["zpool", "replace", pool, new_disk])
        subprocess.check_call(["zpool", "set", "bootfs", f"{pool}/ROOT"])
        logging.info(f"Đã replace boot disk cho pool {pool}")
    except subprocess.CalledProcessError as e:
        logging.error(f"Lỗi replace boot disk: {e}")


@register_command
def d_zfs_disk_format_boot_disk():
    """Format boot disk cho ZFS."""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    logging.info("Format boot disk: cần xác nhận thủ công")
    print("⚠️  Lệnh này sẽ format boot disk. Hãy cẩn thận!")
    print("Tham khảo: zpool create -f rpool /dev/disk/by-id/...")
