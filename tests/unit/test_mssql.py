#!/usr/bin/env python3
"""Tests for mssql.py — SQLSRV/SQL Server setup (migrated from mssql.sh)."""
import os
import sys
import unittest
from unittest.mock import MagicMock, mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import mssql


class TestUbuntuRelease(unittest.TestCase):
    def test_reads_version_id(self):
        data = 'NAME="Ubuntu"\nVERSION_ID="22.04"\nID=ubuntu\n'
        with patch("builtins.open", mock_open(read_data=data)):
            self.assertEqual(mssql._ubuntu_release(), "22.04")

    def test_strips_quotes(self):
        with patch("builtins.open", mock_open(read_data='VERSION_ID="24.04"\n')):
            self.assertEqual(mssql._ubuntu_release(), "24.04")

    def test_returns_empty_when_missing(self):
        with patch("builtins.open", side_effect=FileNotFoundError):
            self.assertEqual(mssql._ubuntu_release(), "")

    def test_returns_empty_without_version_id(self):
        with patch("builtins.open", mock_open(read_data="NAME=Fedora\n")):
            self.assertEqual(mssql._ubuntu_release(), "")


class TestCheckPlatform(unittest.TestCase):
    @patch("utils.mssql._ubuntu_release", return_value="22.04")
    @patch("utils.system_os._os_distro", return_value="ubuntu")
    def test_accepts_supported_ubuntu(self, _distro, _release):
        self.assertEqual(mssql._check_platform(), "22.04")

    @patch("utils.mssql.logging.error")
    @patch("utils.system_os._os_distro", return_value="debian")
    def test_rejects_non_ubuntu(self, _distro, mock_error):
        self.assertIsNone(mssql._check_platform())
        mock_error.assert_called_once()

    @patch("utils.mssql.logging.error")
    @patch("utils.mssql._ubuntu_release", return_value="18.04")
    @patch("utils.system_os._os_distro", return_value="ubuntu")
    def test_rejects_unsupported_release(self, _distro, _release, mock_error):
        """Bash hardcode 16.04-22.04; 18.04 không còn được Microsoft hỗ trợ."""
        self.assertIsNone(mssql._check_platform())
        mock_error.assert_called_once()

    @patch("utils.mssql.logging.error")
    @patch("utils.mssql._ubuntu_release", return_value="")
    @patch("utils.system_os._os_distro", return_value="ubuntu")
    def test_rejects_unknown_release(self, _distro, _release, mock_error):
        self.assertIsNone(mssql._check_platform())


class TestRepoKey(unittest.TestCase):
    @patch("utils.mssql.os.chmod")
    @patch("utils.mssql.os.makedirs")
    @patch("builtins.open", new_callable=mock_open)
    @patch("urllib.request.urlopen")
    def test_writes_keyring_not_aptkey(self, mock_url, mock_file, _makedirs, _chmod):
        """apt-key bị bỏ ở Debian 12/Ubuntu 24.04 — phải dùng keyring file."""
        mock_url.return_value.__enter__.return_value.read.return_value = b"KEYDATA"

        self.assertTrue(mssql._install_repo_key())

        path = mock_file.call_args[0][0]
        self.assertEqual(path, mssql.KEYRING_PATH)
        self.assertIn("/etc/apt/keyrings/", path)
        mock_file.return_value.write.assert_called_once_with(b"KEYDATA")

    @patch("urllib.request.urlopen", side_effect=OSError("no network"))
    def test_download_failure_returns_false(self, _url):
        self.assertFalse(mssql._install_repo_key())

    @patch("utils.mssql.os.chmod")
    @patch("builtins.open", side_effect=OSError("denied"))
    @patch("urllib.request.urlopen")
    def test_write_failure_returns_false(self, mock_url, _file, _chmod):
        mock_url.return_value.__enter__.return_value.read.return_value = b"KEY"
        self.assertFalse(mssql._install_repo_key())


class TestAddRepo(unittest.TestCase):
    @patch("utils.mssql.os.chmod")
    @patch("builtins.open", new_callable=mock_open)
    def test_includes_signed_by(self, mock_file, _chmod):
        url = "https://packages.microsoft.com/config/ubuntu/22.04/prod.list"
        self.assertTrue(mssql._add_repo(url, "/tmp/test.list"))

        written = mock_file.return_value.write.call_args[0][0]
        self.assertIn("signed-by=", written)
        self.assertIn(mssql.KEYRING_PATH, written)
        self.assertIn(url, written)

    @patch("builtins.open", side_effect=OSError("denied"))
    def test_write_failure_returns_false(self, _file):
        self.assertFalse(mssql._add_repo("http://x", "/tmp/x.list"))


class TestSqlsrvApt(unittest.TestCase):
    @patch("utils.mssql.subprocess.run")
    @patch("utils.mssql._add_repo", return_value=True)
    @patch("utils.mssql._install_repo_key", return_value=True)
    @patch("utils.mssql._check_platform", return_value="22.04")
    @patch("utils.mssql._is_root", return_value=True)
    def test_adds_mssql_repo(self, _root, _platform, _key, mock_add, mock_run):
        mssql.d_sqlsrv_apt()
        url = mock_add.call_args[0][0]
        self.assertIn("mssql-server-2019.list", url)
        self.assertIn("22.04", url)
        mock_run.assert_called_once()

    @patch("utils.mssql._check_platform", return_value=None)
    @patch("utils.mssql._is_root", return_value=True)
    def test_stops_when_platform_unsupported(self, _root, _platform):
        with patch("utils.mssql._install_repo_key") as mock_key:
            mssql.d_sqlsrv_apt()
        mock_key.assert_not_called()

    @patch("utils.mssql._check_platform", return_value="22.04")
    @patch("utils.mssql._is_root", return_value=False)
    def test_requires_root(self, _root, _platform):
        with patch("utils.mssql._install_repo_key") as mock_key:
            mssql.d_sqlsrv_apt()
        mock_key.assert_not_called()


class TestSqlsrvPhpInstall(unittest.TestCase):
    @patch("utils.mssql.subprocess.call")
    @patch("utils.mssql.subprocess.check_call")
    @patch("utils.mssql.subprocess.run")
    @patch("utils.mssql._add_repo", return_value=True)
    @patch("utils.mssql._check_platform", return_value="22.04")
    @patch("utils.mssql._is_root", return_value=True)
    def test_installs_driver_packages(
        self, _root, _platform, _add, _run, mock_check, _call
    ):
        with patch("utils.mssql.d_sqlsrv_apt"):
            mssql.d_sqlsrv_php_install()

        all_calls = " ".join(" ".join(c[0][0]) for c in mock_check.call_args_list)
        self.assertIn("msodbcsql17", all_calls)
        self.assertIn("unixodbc-dev", all_calls)
        self.assertIn("pecl", all_calls)

    @patch("utils.mssql.subprocess.check_call")
    @patch("utils.mssql.subprocess.run")
    @patch("utils.mssql._add_repo", return_value=True)
    @patch("utils.mssql._check_platform", return_value="22.04")
    @patch("utils.mssql._is_root", return_value=True)
    def test_sets_accept_eula(self, _root, _platform, _add, _run, mock_check):
        with patch("utils.mssql.d_sqlsrv_apt"):
            mssql.d_sqlsrv_php_install()

        for c in mock_check.call_args_list:
            env = c[1].get("env")
            if env and "msodbcsql17" in c[0][0]:
                self.assertEqual(env.get("ACCEPT_EULA"), "Y")
                return
        self.fail("Không tìm thấy lệnh cài msodbcsql17 có ACCEPT_EULA")


class TestPhpScanDir(unittest.TestCase):
    @patch("utils.mssql.subprocess.run")
    def test_parses_ini_path(self, mock_run):
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout="Configuration File (php.ini) Path: /etc/php/8.3/cli\n"
                   "Loaded Configuration File:         /etc/php/8.3/cli/php.ini\n",
        )
        self.assertEqual(mssql._php_scan_dir(), "/etc/php/8.3")

    @patch("utils.mssql.subprocess.run", side_effect=FileNotFoundError)
    def test_returns_none_without_php(self, _run):
        self.assertIsNone(mssql._php_scan_dir())

    @patch("utils.mssql.subprocess.run")
    def test_returns_none_when_no_ini_line(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0, stdout="something else\n")
        self.assertIsNone(mssql._php_scan_dir())


class TestPhpEnableDisable(unittest.TestCase):
    @patch("utils.mssql.subprocess.check_call")
    @patch("utils.mssql.os.makedirs")
    @patch("builtins.open", new_callable=mock_open)
    @patch("utils.mssql._php_scan_dir", return_value="/etc/php/8.3")
    @patch("utils.mssql._is_root", return_value=True)
    def test_enable_writes_mods_and_calls_phpenmod(
        self, _root, _scan, mock_file, _mk, mock_call
    ):
        mssql.d_sqlsrv_php_enable()

        written = "".join(
            c[0][0] for c in mock_file.return_value.write.call_args_list
        )
        self.assertIn("sqlsrv.so", written)
        self.assertIn("pdo_sqlsrv.so", written)
        mock_call.assert_called_once_with(["phpenmod", "sqlsrv", "pdo_sqlsrv"])

    @patch("utils.mssql.subprocess.check_call")
    @patch("utils.mssql._php_scan_dir", return_value=None)
    @patch("utils.mssql._is_root", return_value=True)
    def test_enable_without_php_dir(self, _root, _scan, mock_call):
        mssql.d_sqlsrv_php_enable()
        mock_call.assert_not_called()

    @patch("utils.mssql.subprocess.check_call")
    @patch("utils.mssql._is_root", return_value=True)
    def test_disable_calls_phpdismod(self, _root, mock_call):
        mssql.d_sqlsrv_php_disable()
        mock_call.assert_called_once_with(["phpdismod", "sqlsrv", "pdo_sqlsrv"])


class TestAliases(unittest.TestCase):
    def test_bash_names_are_registered(self):
        from utils.registry import COMMANDS

        for name in (
            "sqlsrv:apt",
            "sqlsrv:apt:install",
            "sqlsrv:install",
            "mssql:install",
            "sqlsrv:php:install",
            "sqlsrv:php:enable",
            "sqlsrv:php:disable",
            "mssql:php:install",
            "mssql:php:enable",
            "mssql:php:disable",
        ):
            self.assertIn(name, COMMANDS, f"{name} chưa được đăng ký")

    @patch("utils.mssql.d_sqlsrv_apt")
    def test_alias_delegates(self, mock_apt):
        mssql.d_sqlsrv_apt_install()
        mock_apt.assert_called_once()


if __name__ == "__main__":
    unittest.main(verbosity=2)
