#!/usr/bin/env python3
"""Test apt.py: safe APT command behavior."""
import os
import sys
import unittest
from unittest.mock import MagicMock, call, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import apt


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


class TestAptInstall(unittest.TestCase):
    @patch("utils.apt._is_root", return_value=True)
    @patch("utils.apt._is_installed", side_effect=[True, False])
    @patch("utils.apt._run_argv")
    def test_install_skips_installed_and_installs_missing(self, mock_run, mock_installed, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_install(["bash", "curl"])

        mock_installed.assert_has_calls([call("bash"), call("curl")])
        mock_run.assert_called_once_with(["apt-get", "install", "-y", "curl"])

    @patch("utils.apt._is_root", return_value=False)
    @patch("utils.apt._is_installed", return_value=False)
    @patch("utils.apt._run_argv")
    def test_install_uses_sudo_when_not_root(self, mock_run, _installed, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_install(["curl"])

        mock_run.assert_called_once_with(["sudo", "apt-get", "install", "-y", "curl"])

    @patch("utils.apt._is_root", return_value=True)
    @patch("utils.apt._is_installed", return_value=False)
    @patch("utils.apt._run_argv", return_value=(100, "", "failed"))
    def test_install_exits_nonzero_on_failure(self, _run, _installed, _root):
        with self.assertRaises(SystemExit) as ctx:
            apt.d_apt_install(["curl"])

        self.assertEqual(ctx.exception.code, 1)


class TestAptRemove(unittest.TestCase):
    @patch("utils.apt._is_root", return_value=True)
    @patch("utils.apt._run_argv")
    def test_remove_purges_then_autoremoves(self, mock_run, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_remove(["curl", "wget"])

        mock_run.assert_has_calls([
            call(["apt-get", "purge", "-y", "curl", "wget"]),
            call(["apt-get", "autoremove", "-y", "--purge"]),
        ])

    @patch("utils.apt._is_root", return_value=False)
    @patch("utils.apt._run_argv")
    def test_remove_uses_sudo_when_not_root(self, mock_run, _root):
        mock_run.return_value = (0, "", "")

        apt.d_apt_remove(["curl"])

        mock_run.assert_any_call(["sudo", "apt-get", "purge", "-y", "curl"])
        mock_run.assert_any_call(["sudo", "apt-get", "autoremove", "-y", "--purge"])

    def test_remove_rejects_invalid_package_name(self):
        with self.assertRaises(SystemExit) as ctx:
            apt.d_apt_remove(["curl && whoami"])

        self.assertEqual(ctx.exception.code, 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
