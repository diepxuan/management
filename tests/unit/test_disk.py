#!/usr/bin/env python3
"""Test disk.py: disk:check argument parsing."""
import sys
import os
import unittest
from unittest.mock import patch, MagicMock, call

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils.disk import d_disk_check


class TestDiskCheckArgs(unittest.TestCase):
    """Tests cho argument parsing của disk:check."""

    @patch("utils.disk._check_disk_health")
    def test_no_args_checks_all_three(self, mock_check):
        """Không truyền args → chạy cả 3 mode: 4k, 8k, 512."""
        d_disk_check()
        self.assertEqual(mock_check.call_count, 3)
        mock_check.assert_has_calls([
            call("4k"),
            call("8k"),
            call("512"),
        ])

    @patch("utils.disk._check_disk_health")
    def test_sector_size_4k(self, mock_check):
        """--sector-size 4k → chỉ check 4k."""
        d_disk_check(["--sector-size", "4k"])
        mock_check.assert_called_once_with("4k")

    @patch("utils.disk._check_disk_health")
    def test_sector_size_8k(self, mock_check):
        """--sector-size 8k → chỉ check 8k."""
        d_disk_check(["--sector-size", "8k"])
        mock_check.assert_called_once_with("8k")

    @patch("utils.disk._check_disk_health")
    def test_sector_size_512(self, mock_check):
        """--sector-size 512 → chỉ check 512."""
        d_disk_check(["--sector-size", "512"])
        mock_check.assert_called_once_with("512")

    @patch("utils.disk._check_disk_health")
    def test_args_as_string(self, mock_check):
        """Args truyền dưới dạng string thay vì list."""
        d_disk_check("--sector-size 8k")
        mock_check.assert_called_once_with("8k")


if __name__ == "__main__":
    unittest.main(verbosity=2)
