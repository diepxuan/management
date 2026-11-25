#!/usr/bin/env python3
"""Tests for wireguard_macos.py and sshfs_macos.py (salvaged from macos/*.sh).

Không chạy được trên Linux, nên test kiểm tra phần sinh plist và phần
delegate — đúng những chỗ dễ sai khi port.
"""
import os
import plistlib
import sys
import unittest
from unittest.mock import MagicMock, mock_open, patch

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "src"))

from utils import sshfs_macos, wireguard_macos


class TestWireguardPlist(unittest.TestCase):
    def test_plist_is_valid_xml(self):
        """Plist phải parse được — nếu không launchd từ chối im lặng."""
        data = plistlib.loads(wireguard_macos.PLIST_TEMPLATE.encode())

        self.assertEqual(data["Label"], "com.wireguard.wg0")
        self.assertEqual(
            data["ProgramArguments"],
            ["/opt/homebrew/bin/wg-quick", "up", "wg0"],
        )

    def test_skips_dns_like_bash_hotfix(self):
        """wg:hotfix sinh wrapper bơm DNS 5 giây/lần; plist mới set biến này."""
        data = plistlib.loads(wireguard_macos.PLIST_TEMPLATE.encode())
        self.assertEqual(data["EnvironmentVariables"]["WG_QUICK_DNS_SKIP"], "1")

    def test_runs_at_load(self):
        data = plistlib.loads(wireguard_macos.PLIST_TEMPLATE.encode())
        self.assertTrue(data["RunAtLoad"])

    def test_keepalive_watches_config(self):
        data = plistlib.loads(wireguard_macos.PLIST_TEMPLATE.encode())
        self.assertIn(
            wireguard_macos.WG_CONFIG, data["KeepAlive"]["PathState"]
        )
        self.assertIn(wireguard_macos.WG_CONFIG, data["WatchPaths"])

    def test_does_not_reference_removed_hotfix_wrapper(self):
        """Bash trỏ tới wg-quick-bash5 (wrapper của wg:hotfix) — nay bỏ."""
        self.assertNotIn("wg-quick-bash5", wireguard_macos.PLIST_TEMPLATE)

    def test_paths_are_absolute(self):
        self.assertTrue(wireguard_macos.LAUNCHD_PLIST.startswith("/Library/"))
        self.assertTrue(wireguard_macos.WG_CONFIG.startswith("/opt/homebrew/"))


class TestWireguardPlatformGuard(unittest.TestCase):
    def test_all_commands_refuse_non_macos(self):
        """Trên Linux, mọi lệnh wg:* phải log lỗi thay vì chạy launchctl."""
        with patch("utils.wireguard_macos.sys.platform", "linux"), patch(
            "utils.wireguard_macos.logging.error"
        ) as mock_error:
            for func in (
                wireguard_macos.d_wg_status,
                wireguard_macos.d_wg_config,
                wireguard_macos.d_wg_install,
                wireguard_macos.d_wg_log,
                wireguard_macos.d_wg_service_install,
                wireguard_macos.d_wg_service_start,
                wireguard_macos.d_wg_service_stop,
                wireguard_macos.d_wg_service_restart,
            ):
                mock_error.reset_mock()
                func()
                mock_error.assert_called_once()

    def test_no_launchctl_on_linux(self):
        with patch("utils.wireguard_macos.sys.platform", "linux"), patch(
            "utils.wireguard_macos.logging.error"
        ), patch("utils.wireguard_macos._run") as mock_run:
            wireguard_macos.d_wg_service_start()
        mock_run.assert_not_called()


class TestWgServiceStopResetsDns(unittest.TestCase):
    """Bash `d_wg:service:stop` gọi `d_dns:set` — thiếu bước này máy mất DNS."""

    @patch("utils.dns.d_dns_set")
    @patch("utils.wireguard_macos._run")
    @patch("utils.wireguard_macos._require_macos", return_value=True)
    def test_calls_dns_set_without_args(self, _macos, _run, mock_dns):
        wireguard_macos.d_wg_service_stop()
        mock_dns.assert_called_once_with()

    @patch("utils.dns.d_dns_set")
    @patch("utils.wireguard_macos._run")
    @patch("utils.wireguard_macos._require_macos", return_value=True)
    def test_bootout_before_dns_reset(self, _macos, mock_run, mock_dns):
        wireguard_macos.d_wg_service_stop()
        mock_run.assert_called_once_with(
            ["launchctl", "bootout", "system", wireguard_macos.LAUNCHD_PLIST],
            check=False,
        )


class TestWgServiceInstall(unittest.TestCase):
    @patch("utils.wireguard_macos.d_wg_service_start")
    @patch("utils.wireguard_macos.d_wg_install")
    @patch("utils.wireguard_macos.os.chmod")
    @patch("builtins.open", new_callable=mock_open)
    @patch("utils.system._is_root", return_value=True)
    @patch("utils.wireguard_macos._require_macos", return_value=True)
    def test_writes_plist_then_starts(
        self, _macos, _root, mock_file, _chmod, _install, mock_start
    ):
        wireguard_macos.d_wg_service_install()

        written = mock_file.return_value.write.call_args[0][0]
        self.assertIn("com.wireguard.wg0", written)
        mock_start.assert_called_once()

    @patch("utils.wireguard_macos.d_wg_service_start")
    @patch("utils.system._is_root", return_value=False)
    @patch("utils.wireguard_macos._require_macos", return_value=True)
    def test_requires_root(self, _macos, _root, mock_start):
        wireguard_macos.d_wg_service_install()
        mock_start.assert_not_called()


class TestSshfsPlist(unittest.TestCase):
    def _render(self, identity="/Users/x/.ssh/id_rsa",
                remote="root@web.corp:/var/www", mount="/Users/x/laravel"):
        return plistlib.loads(
            sshfs_macos.PLIST_TEMPLATE.format(
                identity=identity, remote=remote, mountpoint=mount
            ).encode()
        )

    def test_plist_is_valid_xml(self):
        data = self._render()
        self.assertEqual(data["Label"], "com.user.sshfs")
        self.assertTrue(data["RunAtLoad"])
        self.assertTrue(data["KeepAlive"])

    def test_mount_options_preserved(self):
        """Bash: auto_cache,reconnect,allow_other — dễ bị mất khi port."""
        args = self._render()["ProgramArguments"]
        options = args[args.index("-o") + 1]
        for flag in ("auto_cache", "reconnect", "allow_other"):
            self.assertIn(flag, options)

    def test_remote_and_mount_come_from_args(self):
        data = self._render(remote="u@h:/p", mount="/m/n")
        self.assertEqual(data["ProgramArguments"][-2], "u@h:/p")
        self.assertEqual(data["ProgramArguments"][-1], "/m/n")

    def test_identity_from_argument(self):
        data = self._render(identity="/keys/other")
        args = data["ProgramArguments"]
        self.assertIn("IdentityFile=/keys/other", args[args.index("-o") + 1])

    def test_no_hardcoded_machine_paths(self):
        """Bash hardcode web.diepxuan.corp và /Users/ductn — không được còn."""
        raw = sshfs_macos.PLIST_TEMPLATE
        self.assertNotIn("diepxuan", raw)
        self.assertNotIn("/Users/ductn", raw)


class TestSshfsServiceInstall(unittest.TestCase):
    @patch("utils.sshfs_macos.d_sshfs_service_restart")
    @patch("utils.sshfs_macos.d_sshfs_install")
    @patch("utils.sshfs_macos.os.chmod")
    @patch("utils.sshfs_macos.os.makedirs")
    @patch("builtins.open", new_callable=mock_open)
    @patch("utils.sshfs_macos.os.path.isfile", return_value=True)
    @patch("utils.system._is_root", return_value=True)
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_writes_plist_with_args(
        self, _macos, _root, _isfile, mock_file, _mk, _chmod, _install, mock_restart
    ):
        sshfs_macos.d_sshfs_service_install(["u@h:/p", "/m/n"])

        written = mock_file.return_value.write.call_args[0][0]
        self.assertIn("u@h:/p", written)
        self.assertIn("/m/n", written)
        mock_restart.assert_called_once()

    @patch("utils.sshfs_macos.d_sshfs_service_restart")
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_requires_two_args(self, _macos, mock_restart):
        with patch("utils.sshfs_macos.logging.error") as mock_error:
            sshfs_macos.d_sshfs_service_install(["only-one"])
        mock_error.assert_called_once()
        mock_restart.assert_not_called()

    @patch("utils.sshfs_macos.d_sshfs_service_restart")
    @patch("utils.system._is_root", return_value=False)
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_requires_root(self, _macos, _root, mock_restart):
        sshfs_macos.d_sshfs_service_install(["u@h:/p", "/m/n"])
        mock_restart.assert_not_called()

    @patch("utils.sshfs_macos.os.environ", {"DUCTN_SSHFS_IDENTITY": "/custom/key"})
    @patch("utils.sshfs_macos.d_sshfs_service_restart")
    @patch("utils.sshfs_macos.d_sshfs_install")
    @patch("utils.sshfs_macos.os.chmod")
    @patch("utils.sshfs_macos.os.makedirs")
    @patch("builtins.open", new_callable=mock_open)
    @patch("utils.sshfs_macos.os.path.isfile", return_value=True)
    @patch("utils.system._is_root", return_value=True)
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_identity_from_env(
        self, _macos, _root, _isfile, mock_file, _mk, _chmod, _install, _restart
    ):
        sshfs_macos.d_sshfs_service_install(["u@h:/p", "/m/n"])
        written = mock_file.return_value.write.call_args[0][0]
        self.assertIn("IdentityFile=/custom/key", written)


class TestSshfsServiceStartStop(unittest.TestCase):
    @patch("utils.sshfs_macos._run")
    @patch("utils.sshfs_macos.os.path.isfile", return_value=True)
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_start_bootstraps_and_enables(self, _macos, _isfile, mock_run):
        sshfs_macos.d_sshfs_service_start()
        cmds = [c[0][0] for c in mock_run.call_args_list]
        self.assertIn(
            ["launchctl", "bootstrap", "system", sshfs_macos.LAUNCHD_PLIST], cmds
        )
        self.assertIn(
            ["launchctl", "enable", f"system/{sshfs_macos.LAUNCHD_LABEL}"], cmds
        )

    @patch("utils.sshfs_macos._run")
    @patch("utils.sshfs_macos.os.path.isfile", return_value=False)
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_start_without_plist(self, _macos, _isfile, mock_run):
        with patch("utils.sshfs_macos.logging.error") as mock_error:
            sshfs_macos.d_sshfs_service_start()
        mock_error.assert_called_once()
        mock_run.assert_not_called()

    @patch("utils.sshfs_macos._run")
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_stop_bootouts(self, _macos, mock_run):
        sshfs_macos.d_sshfs_service_stop()
        mock_run.assert_called_once_with(
            ["launchctl", "bootout", "system", sshfs_macos.LAUNCHD_PLIST]
        )

    @patch("utils.sshfs_macos.d_sshfs_service_start")
    @patch("utils.sshfs_macos.d_sshfs_service_stop")
    @patch("utils.sshfs_macos._require_macos", return_value=True)
    def test_restart_stops_then_starts(self, _macos, mock_stop, mock_start):
        sshfs_macos.d_sshfs_service_restart()
        mock_stop.assert_called_once()
        mock_start.assert_called_once()


class TestSshfsInstalledHelpers(unittest.TestCase):
    @patch("shutil.which")
    def test_install_skips_when_present(self, mock_which):
        mock_which.return_value = "/opt/homebrew/bin/sshfs"
        with patch("utils.sshfs_macos._run") as mock_run:
            sshfs_macos.d_sshfs_install()
        mock_run.assert_not_called()

    @patch("shutil.which")
    def test_install_requires_brew(self, mock_which):
        mock_which.return_value = None
        with patch("utils.sshfs_macos._run") as mock_run, patch(
            "utils.sshfs_macos.logging.error"
        ) as mock_error:
            sshfs_macos.d_sshfs_install()
        mock_run.assert_not_called()
        mock_error.assert_called_once()


if __name__ == "__main__":
    unittest.main(verbosity=2)
