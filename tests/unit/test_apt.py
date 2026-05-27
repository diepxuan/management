#!/usr/bin/env python3
"""Test apt.py: safe APT command behavior."""
import os
import sys
import unittest
from unittest.mock import MagicMock, call, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import apt
from utils.registry import COMMANDS


class TestAptCommandSurface(unittest.TestCase):
    def test_only_check_and_fix_are_active(self):
        self.assertIn("apt:check", COMMANDS)
        self.assertIn("apt:fix", COMMANDS)
        self.assertNotIn("apt:install", COMMANDS)
        self.assertNotIn("apt:remove", COMMANDS)
        self.assertNotIn("apt:uninstall", COMMANDS)


class TestAptCheck(unittest.TestCase):
    @patch("utils.apt.subprocess.run")
    def test_check_prints_1_when_installed(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0, stdout="install ok installed", stderr="")

        with patch("builtins.print") as mock_print:
            apt.d_apt_check(["bash"])

        mock_run.assert_called_once_with(
            ["dpkg-query", "-W", "-f=${Status}", "bash"],
            check=False,
            capture_output=True,
            text=True,
        )
        mock_print.assert_called_once_with("1")

    @patch("utils.apt.subprocess.run")
    def test_check_prints_0_when_missing(self, mock_run):
        mock_run.return_value = MagicMock(returncode=1, stdout="", stderr="")

        with patch("builtins.print") as mock_print:
            apt.d_apt_check(["missing-package"])

        mock_print.assert_called_once_with("0")

    def test_check_rejects_invalid_package_name(self):
        with self.assertRaises(SystemExit) as ctx:
            apt.d_apt_check(["bash;rm -rf /"])

        self.assertEqual(ctx.exception.code, 2)


class TestAptFix(unittest.TestCase):
    @patch("utils.apt._is_root", return_value=True)
    @patch("utils.apt._find_lock_holders", return_value={})
    @patch("utils.apt._remove_lock_files")
    @patch("utils.apt._run_argv")
    def test_fix_repairs_and_unlocks_when_no_lock_holders(self, mock_run, mock_remove, _holders, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_fix([])

        mock_remove.assert_called_once()
        mock_run.assert_has_calls([
            call(["dpkg", "--configure", "-a"]),
            call(["apt-get", "-f", "install", "-y"]),
        ])

    @patch("utils.apt._find_lock_holders", return_value={123: "apt-get install curl"})
    def test_fix_reports_lock_holders_without_force(self, _holders):
        with self.assertRaises(SystemExit) as ctx:
            apt.d_apt_fix([])

        self.assertEqual(ctx.exception.code, 3)

    @patch("utils.apt._is_root", return_value=True)
    @patch("utils.apt._find_lock_holders", return_value={123: "apt-get install curl", 456: "dpkg --configure -a"})
    @patch("utils.apt._kill_processes")
    @patch("utils.apt._remove_lock_files")
    @patch("utils.apt._run_argv")
    def test_fix_force_kills_lock_holders_then_repairs(self, mock_run, mock_remove, mock_kill, _holders, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_fix(["--force"])

        mock_kill.assert_called_once_with([123, 456])
        mock_remove.assert_called_once()
        mock_run.assert_has_calls([
            call(["dpkg", "--configure", "-a"]),
            call(["apt-get", "-f", "install", "-y"]),
        ])

    @patch("utils.apt._is_root", return_value=False)
    @patch("utils.apt._find_lock_holders", return_value={123: "apt-get install curl"})
    @patch("utils.apt._kill_processes")
    @patch("utils.apt._remove_lock_files")
    @patch("utils.apt._run_argv")
    def test_fix_short_force_alias_uses_sudo(self, mock_run, _remove, mock_kill, _holders, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_fix(["-f"])

        mock_kill.assert_called_once_with([123])
        mock_run.assert_has_calls([
            call(["sudo", "dpkg", "--configure", "-a"]),
            call(["sudo", "apt-get", "-f", "install", "-y"]),
        ])


if __name__ == "__main__":
    unittest.main(verbosity=2)
