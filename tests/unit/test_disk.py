#!/usr/bin/env python3
"""Test disk.py: disk:check argument parsing + ZFS replace helpers."""
import sys
import os
import unittest
from unittest.mock import patch, mock_open, MagicMock, call

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import disk
from utils.disk import d_disk_check


class TestDiskCheckArgs(unittest.TestCase):
    """disk:check đo throughput bằng dd (port từ bash), không dùng smartctl."""

    @patch("utils.disk._run_profile")
    def test_no_args_runs_8k_and_512k(self, mock_run):
        """Không truyền args → chạy 8k và 512k, đúng như bash gốc."""
        d_disk_check()
        self.assertEqual(mock_run.call_count, 2)
        mock_run.assert_has_calls([call("8k"), call("512k")])

    @patch("utils.disk._run_profile")
    def test_sector_size_8k(self, mock_run):
        d_disk_check(["--sector-size", "8k"])
        mock_run.assert_called_once_with("8k")

    @patch("utils.disk._run_profile")
    def test_sector_size_512k(self, mock_run):
        d_disk_check(["--sector-size", "512k"])
        mock_run.assert_called_once_with("512k")

    @patch("utils.disk._run_profile")
    def test_args_as_string(self, mock_run):
        """Args truyền dưới dạng string thay vì list."""
        d_disk_check("--sector-size 8k")
        mock_run.assert_called_once_with("8k")

    @patch("utils.disk._run_profile")
    def test_short_flag(self, mock_run):
        d_disk_check(["-s", "512k"])
        mock_run.assert_called_once_with("512k")

    @patch("utils.disk._dd_write_test", return_value=123.4)
    def test_run_profile_unknown_name(self, mock_dd):
        """Profile không hợp lệ không được chạy dd."""
        disk._run_profile("16k")
        mock_dd.assert_not_called()

    @patch("utils.disk._dd_write_test", return_value=99.5)
    def test_run_profile_prints_speed(self, mock_dd):
        with patch("builtins.print") as mock_print:
            disk._run_profile("8k")
        mock_dd.assert_called_once_with("8k", 10240)
        mock_print.assert_called_once_with("8k: 99.5 MB/s")


class TestDdWriteTest(unittest.TestCase):
    """_dd_write_test chạy dd rồi xoá file tạm."""

    @patch("utils.disk.os.remove")
    @patch("utils.disk.os.path.exists", return_value=True)
    @patch("utils.disk.subprocess.run")
    def test_parses_mb_per_second(self, mock_run, _exists, mock_remove):
        mock_run.return_value = MagicMock(
            returncode=0,
            stderr="1073741824 bytes (1.1 GB, 1.0 GiB) copied, 8.5 s, 126 MB/s",
        )
        speed = disk._dd_write_test("8k", 10240)
        self.assertAlmostEqual(speed, 126.0, places=1)
        mock_remove.assert_called_once()

    @patch("utils.disk.os.remove")
    @patch("utils.disk.os.path.exists", return_value=True)
    @patch("utils.disk.subprocess.run")
    def test_parses_gb_per_second(self, mock_run, _exists, _remove):
        mock_run.return_value = MagicMock(
            returncode=0,
            stderr="copied, 2.0 s, 1.5 GB/s",
        )
        speed = disk._dd_write_test("512k", 1024)
        self.assertAlmostEqual(speed, 1536.0, places=1)

    @patch("utils.disk.subprocess.run")
    def test_returns_none_on_dd_failure(self, mock_run):
        mock_run.return_value = MagicMock(returncode=1, stderr="No space left")
        self.assertIsNone(disk._dd_write_test("8k", 10240))

    @patch("utils.disk.subprocess.run", side_effect=FileNotFoundError)
    def test_returns_none_when_dd_missing(self, _run):
        self.assertIsNone(disk._dd_write_test("8k", 10240))

    @patch("utils.disk.os.remove")
    @patch("utils.disk.os.path.exists", return_value=True)
    @patch("utils.disk.subprocess.run")
    def test_always_removes_temp_file(self, mock_run, _exists, mock_remove):
        """File tạm phải bị xoá kể cả khi dd lỗi."""
        mock_run.return_value = MagicMock(returncode=1, stderr="error")
        disk._dd_write_test("8k", 10240)
        mock_remove.assert_called_once()


class TestZfsReplaceDisk(unittest.TestCase):
    """`zfs:disk:replace:disk` — phần salvage từ bash, trước đây không có."""

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_runs_zpool_replace_with_force(self, _root, mock_call):
        disk.d_zfs_disk_replace_disk(["rpool", "/dev/old-part3", "/dev/new-part3"])
        mock_call.assert_called_once_with(
            ["zpool", "replace", "-f", "rpool", "/dev/old-part3", "/dev/new-part3"]
        )

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_requires_three_args(self, _root, mock_call):
        disk.d_zfs_disk_replace_disk(["rpool", "/dev/old"])
        mock_call.assert_not_called()

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=False)
    def test_requires_root(self, _root, mock_call):
        disk.d_zfs_disk_replace_disk(["rpool", "/dev/old", "/dev/new"])
        mock_call.assert_not_called()


class TestZfsReplaceBoot(unittest.TestCase):
    """`zfs:disk:replace:boot` — thay đĩa boot Proxmox (sgdisk + zpool replace)."""

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_runs_three_steps(self, _root, mock_call):
        disk.d_zfs_disk_replace_boot(["/dev/old", "/dev/new"])
        self.assertEqual(mock_call.call_count, 3)

        calls = [c[0][0] for c in mock_call.call_args_list]
        self.assertEqual(calls[0], ["sgdisk", "/dev/old", "-R", "/dev/new"])
        self.assertEqual(calls[1], ["sgdisk", "-G", "/dev/new"])
        self.assertEqual(
            calls[2], ["zpool", "replace", "-f", "rpool", "/dev/old-part3", "/dev/new-part3"]
        )

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_custom_pool(self, _root, mock_call):
        disk.d_zfs_disk_replace_boot(["/dev/old", "/dev/new", "--pool", "rpool2"])
        calls = [c[0][0] for c in mock_call.call_args_list]
        self.assertEqual(
            calls[2],
            ["zpool", "replace", "-f", "rpool2", "/dev/old-part3", "/dev/new-part3"],
        )

    @patch("utils.disk.subprocess.check_call", side_effect=FileNotFoundError)
    @patch("utils.disk._is_root", return_value=True)
    def test_missing_sgdisk_is_handled(self, _root, _call):
        """Thiếu sgdisk không được raise ra ngoài."""
        disk.d_zfs_disk_replace_boot(["/dev/old", "/dev/new"])

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_requires_two_args(self, _root, mock_call):
        disk.d_zfs_disk_replace_boot(["/dev/old"])
        mock_call.assert_not_called()


class TestZfsFormatBoot(unittest.TestCase):
    """`zfs:disk:format:boot:disk` — chạy proxmox-boot-tool (trước chỉ in cảnh báo)."""

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk.input", return_value="y")
    @patch("utils.disk._is_root", return_value=True)
    def test_formats_after_confirmation(self, _root, _input, mock_call):
        disk.d_zfs_disk_format_boot_disk(["/dev/sdb2"])
        self.assertEqual(mock_call.call_count, 2)
        calls = [c[0][0] for c in mock_call.call_args_list]
        self.assertEqual(calls[0], ["proxmox-boot-tool", "format", "/dev/sdb2"])
        self.assertEqual(calls[1], ["proxmox-boot-tool", "init", "/dev/sdb2"])

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk.input", return_value="n")
    @patch("utils.disk._is_root", return_value=True)
    def test_aborts_without_confirmation(self, _root, _input, mock_call):
        disk.d_zfs_disk_format_boot_disk(["/dev/sdb2"])
        mock_call.assert_not_called()

    @patch("utils.disk.subprocess.check_call")
    @patch("utils.disk._is_root", return_value=True)
    def test_aborts_on_eof(self, _root, mock_call):
        with patch("utils.disk.input", side_effect=EOFError):
            disk.d_zfs_disk_format_boot_disk(["/dev/sdb2"])
        mock_call.assert_not_called()


class TestZfsReplaceBootDiskDeprecated(unittest.TestCase):
    """Tên cũ vẫn chạy nhưng đi qua hàm mới."""

    @patch("utils.disk.d_zfs_disk_replace_boot")
    def test_delegates_to_new_function(self, mock_new):
        disk.d_zfs_disk_replace_boot_disk(["/dev/old", "/dev/new"])
        mock_new.assert_called_once_with(["/dev/old", "/dev/new"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
