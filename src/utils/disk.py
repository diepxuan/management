#!/usr/bin/env python3

import logging
import os
import re
import subprocess
import tempfile

from .registry import register_command
from .system import _is_root

# Bash `disk.sh` (deprecated) đo throughput ghi tuần tự bằng dd, không phải
# smartctl. Ba command gốc:
#   sys:disk:check      = check8k + check512k
#   sys:disk:check8k    = dd bs=8k count=10k    (80 MB)
#   sys:disk:check512k  = dd bs=512k count=1k   (512 MB)
# Python trước 5.8.7 chạy `smartctl -a /dev/sda` cho cả ba — sai mục đích và
# hardcode thiết bị. Nay port lại đúng dd, thêm `smartctl` thành command riêng.

# (block size, count, kích thước thực, mô tả)
_DD_PROFILES = {
    "8k": ("8k", 10240, 80, "80 MB — giống bash sys:disk:check8k"),
    "512k": ("512k", 1024, 512, "512 MB — giống bash sys:disk:check512k"),
    "4k": ("4k", 20480, 80, "80 MB — profile thêm ở 5.8.7, không có trong bash"),
}


def _dd_write_test(block_size, count):
    """
    Ghi tuần tự ``block_size * count`` byte rồi xoá.

    Trả về throughput MB/s đọc từ stderr của dd, hoặc None nếu lỗi.
    """
    tmp = os.path.join(tempfile.gettempdir(), "ductn-disk-check")
    try:
        proc = subprocess.run(
            [
                "dd",
                "if=/dev/zero",
                f"of={tmp}",
                f"bs={block_size}",
                f"count={count}",
                "conv=fdatasync",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        logging.error("Không tìm thấy lệnh dd")
        return None
    finally:
        try:
            if os.path.exists(tmp):
                os.remove(tmp)
        except OSError:
            pass

    if proc.returncode != 0:
        logging.error("dd thất bại: %s", proc.stderr.strip())
        return None

    # dd in "... copied, 1.234 s, 64.9 MB/s"
    match = re.search(r"([\d.]+)\s*([KMG])B/s", proc.stderr)
    if not match:
        logging.info("dd hoàn tất (không đọc được tốc độ): %s", proc.stderr.strip())
        return None

    value, unit = float(match.group(1)), match.group(2)
    scale = {"K": 1 / 1024, "M": 1, "G": 1024}[unit]
    return value * scale


def _run_profile(name):
    """Chạy một profile dd và in kết quả."""
    if name not in _DD_PROFILES:
        logging.error(
            "Profile không hợp lệ: %s (chọn: %s)", name, ", ".join(_DD_PROFILES)
        )
        return

    block_size, count, size_mb, _desc = _DD_PROFILES[name]

    logging.info(
        "Đang ghi thử %s (bs=%s, %d block, ~%d MB)…", name, block_size, count, size_mb
    )
    speed = _dd_write_test(block_size, count)

    if speed is None:
        print(f"{name}: không đo được")
    else:
        print(f"{name}: {speed:.1f} MB/s")


@register_command
def d_disk_check(args=None):
    """
    Đo throughput ghi tuần tự của đĩa (port từ bash `sys:disk:check`).
    Usage: ductn disk:check [--sector-size 4k|8k|512k]

    Không truyền tham số thì chạy cả 8k và 512k, đúng như bash gốc.
    Ghi vào $TMPDIR rồi xoá ngay; cần ~512 MB trống.
    """
    profile = None
    if args:
        arg_list = args if isinstance(args, list) else args.split()
        for i, token in enumerate(arg_list):
            if token in ("--sector-size", "-s") and i + 1 < len(arg_list):
                profile = arg_list[i + 1]

    if profile:
        _run_profile(profile)
    else:
        for name in ("8k", "512k"):
            _run_profile(name)


@register_command
def d_disk_health(args=None):
    """
    Kiểm tra SMART health của đĩa.
    Usage: ductn disk:health [device]   (mặc định /dev/sda)

    Tách ra từ Python cũ (vốn gọi smartctl trong disk:check).
    """
    device = "/dev/sda"
    if args:
        device = args[0] if isinstance(args, list) else args

    try:
        result = subprocess.run(
            ["smartctl", "-a", device],
            capture_output=True,
            text=True,
            check=False,
        )
        print(result.stdout)
    except FileNotFoundError:
        logging.error("Không tìm thấy smartctl. Cài đặt: apt install smartmontools")


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
    """Take ZFS disk offline. Usage: ductn zfs:disk:offline <pool> <disk>"""
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 2:
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
    """
    Thay một đĩa trong pool (pool còn sống, đĩa cũ vẫn truy cập được).
    Usage: ductn zfs:disk:replace <pool> <old_disk> [new_disk]

    Không truyền new_disk thì zpool replace chạy chế độ thay tại chỗ
    (dùng khi ổ mới đã gắn vào cùng slot).
    """
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


def _copy_partition_table(src, dst):
    """Sao chép nguyên partition table từ ``src`` sang ``dst`` (sgdisk -R)."""
    subprocess.check_call(["sgdisk", src, "-R", dst])


def _randomize_guids(disk):
    """Cấp GUID mới cho đĩa và các partition (sgdisk -G)."""
    subprocess.check_call(["sgdisk", "-G", disk])


@register_command
def d_zfs_disk_replace_disk(args=None):
    """
    Thay đĩa trong pool RAIDZ (kể cả đĩa hỏng) — port từ bash
    `zfs:disk:replace_disk`, phần chưa từng có trong Python.
    Usage: ductn zfs:disk:replace:disk <pool> <old_part> <new_part>

    Ví dụ thay 1 đĩa hỏng trong rpool mirror/raidz:
      ductn zfs:disk:replace:disk rpool \\
        /dev/disk/by-id/ata-HITACHI_HUA722010ALA330_J80TS2LL-part3 \\
        /dev/disk/by-id/ata-HGST_HTS721010A9E630_JR100XBN1LH00E-part3

    Bash gốc chỉ chạy `zpool replace -f`. Ở đây thêm bước copy partition
    table + randomize GUID khi đĩa mới là đĩa trắng (xem
    `zfs:disk:replace:boot` cho đĩa boot).
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 3:
        logging.error(
            "Usage: ductn zfs:disk:replace:disk <pool> <old_part> <new_part>"
        )
        return

    pool, old_part, new_part = args[0], args[1], args[2]

    logging.info("replace_disk pool=%s old=%s new=%s", pool, old_part, new_part)
    try:
        subprocess.check_call(["zpool", "replace", "-f", pool, old_part, new_part])
        logging.info("Đã thay %s bằng %s trong pool %s", old_part, new_part, pool)
        logging.info("Theo dõi tiến trình resilver: zpool status %s", pool)
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi replace đĩa: %s", e)


@register_command
def d_zfs_disk_replace_boot(args=None):
    """
    Thay đĩa BOOT của Proxmox trên ZFS — port từ bash
    `zfs:disk:replace_boot_disk`, phần chưa từng có trong Python.
    Usage: ductn zfs:disk:replace:boot <old_disk> <new_disk> [--pool rpool]

    Ba bước, đúng như comment trong bash gốc:
      1. sgdisk <old> -R <new>     copy partition table
      2. sgdisk -G <new>           cấp GUID mới
      3. zpool replace -f rpool <old>-part3 <new>-part3

    Sau đó cần cài bootloader (proxmox-boot-tool) — xem
    `ductn zfs:disk:format:boot:disk`.
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args or len(args) < 2:
        logging.error(
            "Usage: ductn zfs:disk:replace:boot <old_disk> <new_disk> [--pool rpool]"
        )
        return

    old_disk, new_disk = args[0], args[1]
    pool = "rpool"
    if "--pool" in args:
        idx = args.index("--pool")
        if idx + 1 < len(args):
            pool = args[idx + 1]

    logging.info("Thay đĩa boot: %s -> %s (pool %s)", old_disk, new_disk, pool)

    try:
        logging.info("Bước 1/3: copy partition table")
        _copy_partition_table(old_disk, new_disk)

        logging.info("Bước 2/3: cấp GUID mới cho %s", new_disk)
        _randomize_guids(new_disk)

        logging.info("Bước 3/3: zpool replace")
        subprocess.check_call(
            ["zpool", "replace", "-f", pool, f"{old_disk}-part3", f"{new_disk}-part3"]
        )
    except FileNotFoundError:
        logging.error("Không tìm thấy sgdisk. Cài đặt: apt install gdisk")
        return
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi thay đĩa boot: %s", e)
        return

    logging.info("Xong. Kiểm tra: zpool status %s", pool)
    logging.info("Cài bootloader: ductn zfs:disk:format:boot:disk %s-part2", new_disk)


@register_command
def d_zfs_disk_replace_boot_disk(args=None):
    """
    DEPRECATED — dùng `zfs:disk:replace:boot`.

    Giữ lại để không phá vỡ script cũ. Bản cũ gọi `zpool replace <pool>
    <new_disk>` trực tiếp (thiếu đuôi -part3 và thiếu bước sgdisk), không
    dùng được cho đĩa boot Proxmox.
    """
    logging.warning(
        "zfs:disk:replace_boot_disk đã deprecated, dùng "
        "`ductn zfs:disk:replace:boot <old_disk> <new_disk>`"
    )
    return d_zfs_disk_replace_boot(args)


@register_command
def d_zfs_disk_format_boot_disk(args=None):
    """
    Format phân vùng ESP cho boot Proxmox — port từ bash
    `zfs:disk:format_boot_disk`, phần chưa từng có trong Python.
    Usage: ductn zfs:disk:format:boot:disk <partition> [--pool rpool]

    ESP là partition #2 trên đĩa boot do Proxmox tạo. Bash gốc chỉ có
    comment `proxmox-boot-tool format /dev/sdb2`; nay chạy thật kèm xác nhận.
    """
    if not _is_root():
        logging.error("Cần quyền root (sudo)")
        return

    if not args:
        logging.error(
            "Usage: ductn zfs:disk:format:boot:disk <partition> [--pool rpool]"
        )
        return

    partition = args[0]
    pool = "rpool"
    if "--pool" in args:
        idx = args.index("--pool")
        if idx + 1 < len(args):
            pool = args[idx + 1]

    logging.warning("Sắp format ESP trên %s (pool %s)", partition, pool)
    print(f"Lệnh sẽ chạy: proxmox-boot-tool format {partition}")
    print("Sau đó cần:  proxmox-boot-tool init <partition>")
    print("Tiếp tục? [y/N] ", end="", flush=True)

    try:
        answer = input().strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        logging.info("Đã huỷ")
        return

    if answer not in ("y", "yes"):
        logging.info("Đã huỷ")
        return

    try:
        subprocess.check_call(["proxmox-boot-tool", "format", partition])
        subprocess.check_call(["proxmox-boot-tool", "init", partition])
        logging.info("Đã format + init ESP trên %s", partition)
    except FileNotFoundError:
        logging.error("Không tìm thấy proxmox-boot-tool (chỉ có trên Proxmox VE)")
    except subprocess.CalledProcessError as e:
        logging.error("Lỗi format ESP: %s", e)
